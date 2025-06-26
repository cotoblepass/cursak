-module(my).

-include("constants.hrl").

-export([write64_my_mysql/2, write64_my_mysql_pool/2, write64_my_odbc/2, write64_my_odbc_pool/2, write64_my_odbc_pooling/2]).

table_init(odbc, my_odbc_pool) ->
    pool_my_odbc:squery(my_odbc_pool, "DROP TABLE IF EXISTS app_temp_table64_odbc_pool;"),
    pool_my_odbc:squery(my_odbc_pool, "CREATE TABLE IF NOT EXISTS app_temp_table64_odbc_pool
        (id SERIAL PRIMARY KEY, create_date timestamp, counter integer, ballast text);");
    

table_init(odbc, ConnectionDescr) ->
    odbc:sql_query(ConnectionDescr, "DROP TABLE IF EXISTS app_temp_table64_odbc;"),
    odbc:sql_query(ConnectionDescr, "CREATE TABLE IF NOT EXISTS app_temp_table64_odbc
        (id SERIAL PRIMARY KEY, create_date timestamp, counter integer, ballast text);");

table_init(odbc_pooling, ConnectionDescr) ->
    odbc:sql_query(ConnectionDescr, "DROP TABLE IF EXISTS app_temp_table64_odbc_pooling;"),
    odbc:sql_query(ConnectionDescr, "CREATE TABLE IF NOT EXISTS app_temp_table64_odbc_pooling
        (id SERIAL PRIMARY KEY, create_date timestamp, counter integer, ballast text);");

table_init(my, my_mysql_pool) ->
    pool_my_mysql:squery(my_mysql_pool, <<"DROP TABLE IF EXISTS app_temp_table64_pool ">>),
    pool_my_mysql:squery(my_mysql_pool, <<"CREATE TABLE IF NOT EXISTS app_temp_table64_pool
        (id SERIAL PRIMARY KEY, create_date timestamp, counter integer, ballast text)">>);

table_init(my, ConnectionDescr) ->
    mysql:query(ConnectionDescr, "DROP TABLE IF EXISTS app_temp_table64 ", []),
    mysql:query(ConnectionDescr, "CREATE TABLE IF NOT EXISTS app_temp_table64 
        (id SERIAL PRIMARY KEY, create_date timestamp, counter integer, ballast text)", []).


write64_my_odbc(WsPid, Ballast0) ->
    io:format("write64_my_odbc\n", []),

    Ballast = erlang:binary_to_list(Ballast0),
    {ok, OdbcPool} = application:get_env(cursak, my_odbc_pool),
    [{_,_,PropOdbcPool}] = OdbcPool,
    OdbcMy = proplists:get_value(odbc_my, PropOdbcPool),
    io:format("write64_my_odbc OdbcMy: ~p \n", [OdbcMy]),
    {ok, ConnectionDescr} = odbc:connect(OdbcMy,[]),
    io:format("write64_my_odbc ConnectionDescr: ~p \n", [ConnectionDescr]),
    table_init(odbc, ConnectionDescr),
    
    MaxRowsCounter = ?MAX_ROWS_COUNTER,
    io:format("write64_my_odbc MaxRowsCounter: ~p \n", [MaxRowsCounter]),
    spawn_threads(fun insert_rows_my_odbc/6, ConnectionDescr, WsPid, ?MAX_THREADS_PLUS_ONE, MaxRowsCounter, Ballast),

    {ok}.

write64_my_odbc_pooling(WsPid, Ballast0) ->
    io:format("write64_odbc_pooling\n", []),

    Ballast = erlang:binary_to_list(Ballast0),
    {ok, OdbcPool} = application:get_env(cursak, my_odbc_pool),
    [{_,_,PropOdbcPool}] = OdbcPool,
    OdbcMy = proplists:get_value(odbc_my_pooling, PropOdbcPool),

    {ok, ConnectionDescr} = odbc:connect(OdbcMy,[]),
    table_init(odbc_pooling, ConnectionDescr),
    MaxRowsCounter = ?MAX_ROWS_COUNTER,


    spawn_threads(fun insert_rows_my_odbc_pooling/6, ConnectionDescr, WsPid, ?MAX_THREADS_PLUS_ONE, MaxRowsCounter, Ballast),

    {ok}.

write64_my_mysql(WsPid, Ballast) ->
    io:format("write64_write64_my_mysql\n", []),

    {ok, MyPool} = application:get_env(cursak, my_mysql_pool),
    [{_,_, MyMysqlPool}] = MyPool,
    Hostname = proplists:get_value(hostname_my, MyMysqlPool),
    Database = proplists:get_value(database_my, MyMysqlPool),
    Username = proplists:get_value(username_my, MyMysqlPool),
    Password = proplists:get_value(password_my, MyMysqlPool),
    {ok, ConnectionDescr} = mysql:start_link([{host, Hostname}, {user, Username},
                              {password, Password}, {database, Database}]),
    table_init(my, ConnectionDescr),
    MaxRowsCounter = ?MAX_ROWS_COUNTER,

    spawn_threads(fun insert_rows_my_mysql/6, ConnectionDescr, WsPid, ?MAX_THREADS_PLUS_ONE, MaxRowsCounter, Ballast),

    {ok}.


write64_my_mysql_pool(WsPid, Ballast) ->
    io:format("write64_my_mysql_pool\n", []),

    table_init(my, my_mysql_pool),
    MaxRowsCounter = ?MAX_ROWS_COUNTER,

    spawn_threads(fun insert_rows_my_mysql_pool/6, my_mysql_pool, WsPid, ?MAX_THREADS_PLUS_ONE, MaxRowsCounter, Ballast),

    {ok}.

write64_my_odbc_pool(WsPid, Ballast0) ->
    io:format("write64_odbc_pool\n", []),

    Ballast = erlang:binary_to_list(Ballast0),
    table_init(odbc, my_odbc_pool),
    MaxRowsCounter = ?MAX_ROWS_COUNTER,

        spawn_threads(fun insert_rows_my_odbc_pool/6, my_odbc_pool, WsPid, ?MAX_THREADS_PLUS_ONE, MaxRowsCounter, Ballast),

    {ok}.

insert_rows_my_mysql(Connection, WsPid, StreamNumber, StartTime, MaxRowsCounter, Ballast) ->
    io:format("[my] {insert_rows_my_mysql} start StreamNumber: ~p\n", [StreamNumber]),
    insert_rows_my_mysql(Connection, WsPid, StreamNumber, StartTime, MaxRowsCounter, 0, Ballast).

insert_rows_my_mysql(_, WsPid, StreamNumber, StartTime, MaxRowsCounter, MaxRowsCounter, _) ->
    io:format("[my] {insert_rows_my_mysql} end StreamNumber: ~p\n", [StreamNumber]),
    WsPid ! {response2client, #{
        <<"db">> => <<"my">>,
        <<"lib">> => <<"mysql">>,
        <<"pool">> => false,
        <<"stream_number">> => StreamNumber,
        <<"start_time">> => StartTime,
        <<"end_time">> => erlang:system_time()}},
    ok;

insert_rows_my_mysql(Connection, WsPid, StreamNumber, StartTime, MaxRowsCounter, RowsCounter, Ballast) ->

    mysql:query(
        Connection,
        "INSERT INTO app_temp_table64( create_date, counter, ballast) VALUES (now(), ?, ?)",
        [RowsCounter, Ballast]
    ),
    insert_rows_my_mysql(Connection, WsPid, StreamNumber, StartTime, MaxRowsCounter, RowsCounter + 1, Ballast).



insert_rows_my_odbc(Connection, WsPid, StreamNumber, StartTime, MaxRowsCounter, Ballast) ->
    io:format("[my] {insert_rows_my_odbc} start StreamNumber: ~p\n", [StreamNumber]),
    insert_rows_my_odbc(Connection, WsPid, StreamNumber, StartTime, MaxRowsCounter, 0, Ballast).

insert_rows_my_odbc(_, WsPid, StreamNumber, StartTime, MaxRowsCounter, MaxRowsCounter, _) ->
    io:format("[my] {insert_rows_my_odbc} end StreamNumber: ~p\n", [StreamNumber]),
    WsPid ! {response2client, #{
        <<"db">> => <<"my">>,
        <<"lib">> => <<"odbc">>,
        <<"pool">> => false,
        <<"stream_number">> => StreamNumber,
        <<"start_time">> => StartTime,
        <<"end_time">> => erlang:system_time()}},
    ok;

insert_rows_my_odbc(Connection, WsPid, StreamNumber, StartTime, MaxRowsCounter, RowsCounter, Ballast) ->

    odbc:param_query(Connection,
        "INSERT INTO app_temp_table64_odbc( create_date, counter, ballast) VALUES (now(), ?, ?);",
        [{sql_integer,[RowsCounter]},{{sql_varchar, 100000},[Ballast]}]),
    insert_rows_my_odbc(Connection, WsPid, StreamNumber, StartTime, MaxRowsCounter, RowsCounter + 1, Ballast).



insert_rows_my_odbc_pooling(Connection, WsPid, StreamNumber, StartTime, MaxRowsCounter, Ballast) ->
    io:format("[my] {insert_rows_my_odbc_pooling} start StreamNumber: ~p\n", [StreamNumber]),
    insert_rows_my_odbc_pooling(Connection, WsPid, StreamNumber, StartTime, MaxRowsCounter, 0, Ballast).

insert_rows_my_odbc_pooling(_, WsPid, StreamNumber, StartTime, MaxRowsCounter, MaxRowsCounter, _) ->
    io:format("[my] {insert_rows_my_odbc_pooling} end StreamNumber: ~p\n", [StreamNumber]),
    WsPid ! {response2client, #{
        <<"db">> => <<"my">>,
        <<"lib">> => <<"odbc_pooling">>,
        <<"pool">> => false,
        <<"stream_number">> => StreamNumber,
        <<"start_time">> => StartTime,
        <<"end_time">> => erlang:system_time()}},
    ok;

insert_rows_my_odbc_pooling(Connection, WsPid, StreamNumber, StartTime, MaxRowsCounter, RowsCounter, Ballast) ->

    odbc:param_query(Connection,
        "INSERT INTO app_temp_table64_odbc_pooling( create_date, counter, ballast) VALUES (now(), ?, ?);",
        [{sql_integer,[RowsCounter]},{{sql_varchar, 100000},[Ballast]}]),
    insert_rows_my_odbc_pooling(Connection, WsPid, StreamNumber, StartTime, MaxRowsCounter, RowsCounter + 1, Ballast).



insert_rows_my_mysql_pool(Connection, WsPid, StreamNumber, StartTime, MaxRowsCounter, Ballast) ->
    io:format("[my] {insert_rows_my_mysql_pool} start StreamNumber: ~p\n", [StreamNumber]),
    insert_rows_my_mysql_pool(Connection, WsPid, StreamNumber, StartTime, MaxRowsCounter, 0, Ballast).

insert_rows_my_mysql_pool(_, WsPid, StreamNumber, StartTime, MaxRowsCounter, MaxRowsCounter, _) ->
    io:format("[my] {insert_rows_my_mysql_pool} end StreamNumber: ~p\n", [StreamNumber]),
    WsPid ! {response2client, #{
        <<"db">> => <<"my">>,
        <<"lib">> => <<"mysql">>,
        <<"pool">> => true,
        <<"stream_number">> => StreamNumber,
        <<"start_time">> => StartTime,
        <<"end_time">> => erlang:system_time()}},
    ok;

insert_rows_my_mysql_pool(Connection, WsPid, StreamNumber, StartTime, MaxRowsCounter, RowsCounter, Ballast) ->

    pool_my_mysql:equery(
        Connection,
        "INSERT INTO app_temp_table64_pool( create_date, counter, ballast) VALUES (now(), ?, ?)",
        [RowsCounter, Ballast]
    ),
    insert_rows_my_mysql_pool(Connection, WsPid, StreamNumber, StartTime, MaxRowsCounter, RowsCounter + 1, Ballast).

insert_rows_my_odbc_pool(Connection, WsPid, StreamNumber, StartTime, MaxRowsCounter, Ballast) ->
    io:format("[my] {insert_rows_my_odbc_pool} start StreamNumber: ~p\n", [StreamNumber]),
    insert_rows_my_odbc_pool(Connection, WsPid, StreamNumber, StartTime, MaxRowsCounter, 0, Ballast).

insert_rows_my_odbc_pool(_, WsPid, StreamNumber, StartTime, MaxRowsCounter, MaxRowsCounter, _) ->
    io:format("[my] {insert_rows_my_odbc_pool} end StreamNumber: ~p\n", [StreamNumber]),
    WsPid ! {response2client, #{
        <<"db">> => <<"my">>,
        <<"lib">> => <<"odbc">>,
        <<"pool">> => true,
        <<"stream_number">> => StreamNumber,
        <<"start_time">> => StartTime,
        <<"end_time">> => erlang:system_time()}},
    ok;

insert_rows_my_odbc_pool(Connection, WsPid, StreamNumber, StartTime, MaxRowsCounter, RowsCounter, Ballast) ->

    pool_my_odbc:equery(
        Connection,
        "INSERT INTO app_temp_table64_odbc_pool( create_date, counter, ballast) VALUES (now(), ?, ?);",
        [{sql_integer,[RowsCounter]},{{sql_varchar, 100000},[Ballast]}]
    ),
    insert_rows_my_odbc_pool(Connection, WsPid, StreamNumber, StartTime, MaxRowsCounter, RowsCounter + 1, Ballast).

spawn_threads(_F, _ConnectionDescr, _WsPid, 0, _MaxRowsCounter, _Ballast) ->
    io:format("All threads started\n", []);
spawn_threads(F, ConnectionDescr, WsPid, ?MAX_THREADS_PLUS_ONE, MaxRowsCounter, Ballast) ->
    io:format("We r in\n", []),
    ThreadNumber = ?MAX_THREADS_PLUS_ONE - 1,
    spawn_threads(F, ConnectionDescr, WsPid, ThreadNumber, MaxRowsCounter, Ballast);
spawn_threads(F, ConnectionDescr, WsPid, ThreadNumber, MaxRowsCounter, Ballast) ->
        ThreadPid = 
            spawn(
                fun() -> F(ConnectionDescr, WsPid, ThreadNumber, erlang:system_time(), MaxRowsCounter, Ballast)
            end),
        io:format("ThreadNumber: ~p started. ThreadPid: ~p\n", [ThreadNumber, ThreadPid]),
    spawn_threads(F, ConnectionDescr, WsPid, ThreadNumber - 1, MaxRowsCounter, Ballast) .


