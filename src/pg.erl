-module(pg).

-include("constants.hrl").

-export([write64_epgsql/2, write64_epgsql_pool/2, write64_odbc/2, write64_odbc_pool/2, write64_odbc_pooling/2]).



write64_odbc(WsPid, Ballast0) ->
    io:format("write64_odbc\n", []),

    Ballast = erlang:binary_to_list(Ballast0),
    {ok, OdbcPool} = application:get_env(cursak, pg_odbc_pool),
    [{_,_,PropOdbcPool}] = OdbcPool,
    OdbcPg = proplists:get_value(odbc_pg, PropOdbcPool),
    {ok, ConnectionDescr} = odbc:connect(OdbcPg,[]),
    table_init(odbc, ConnectionDescr),
    MaxRowsCounter = ?MAX_ROWS_COUNTER,

    FunPid1 = 
        spawn(
            fun() -> insert_rows_pg_odbc(ConnectionDescr, WsPid, 1, erlang:system_time(), MaxRowsCounter, Ballast)
        end),
    FunPid2 = 
        spawn(
            fun() -> insert_rows_pg_odbc(ConnectionDescr, WsPid, 2, erlang:system_time(), MaxRowsCounter, Ballast)
        end),
    FunPid3 =
        spawn(
            fun() -> insert_rows_pg_odbc(ConnectionDescr, WsPid, 3, erlang:system_time(), MaxRowsCounter, Ballast)
        end),
    FunPid4 =
        spawn(
            fun() -> insert_rows_pg_odbc(ConnectionDescr, WsPid, 4, erlang:system_time(), MaxRowsCounter, Ballast)
        end),
    FunPid5 =
        spawn(
            fun() -> insert_rows_pg_odbc(ConnectionDescr, WsPid, 5, erlang:system_time(), MaxRowsCounter, Ballast)
        end),

    io:format("write64_odbc end FunPid1:~p\n", [FunPid1]),
    io:format("write64_odbc end FunPid2:~p\n", [FunPid2]),
    io:format("write64_odbc end FunPid3:~p\n", [FunPid3]),
    io:format("write64_odbc end FunPid4:~p\n", [FunPid4]),
    io:format("write64_odbc end FunPid5:~p\n", [FunPid5]),

    {ok}.

write64_odbc_pooling(WsPid, Ballast0) ->
    io:format("write64_odbc_pooling\n", []),

    Ballast = erlang:binary_to_list(Ballast0),
    {ok, OdbcPool} = application:get_env(cursak, pg_odbc_pool),
    [{_,_,PropOdbcPool}] = OdbcPool,
    OdbcPg = proplists:get_value(odbc_pg_pool, PropOdbcPool),
    {ok, ConnectionDescr} = odbc:connect(OdbcPg,[]),
    table_init(odbc_pooling, ConnectionDescr),
    MaxRowsCounter = ?MAX_ROWS_COUNTER,

    FunPid1 = 
        spawn(
            fun() -> insert_rows_pg_odbc_pooling(ConnectionDescr, WsPid, 1, erlang:system_time(), MaxRowsCounter, Ballast)
        end),
    FunPid2 = 
        spawn(
            fun() -> insert_rows_pg_odbc_pooling(ConnectionDescr, WsPid, 2, erlang:system_time(), MaxRowsCounter, Ballast)
        end),
    FunPid3 =
        spawn(
            fun() -> insert_rows_pg_odbc_pooling(ConnectionDescr, WsPid, 3, erlang:system_time(), MaxRowsCounter, Ballast)
        end),
    FunPid4 =
        spawn(
            fun() -> insert_rows_pg_odbc_pooling(ConnectionDescr, WsPid, 4, erlang:system_time(), MaxRowsCounter, Ballast)
        end),
    FunPid5 =
        spawn(
            fun() -> insert_rows_pg_odbc_pooling(ConnectionDescr, WsPid, 5, erlang:system_time(), MaxRowsCounter, Ballast)
        end),

    io:format("write64_odbc_pooling end FunPid1:~p\n", [FunPid1]),
    io:format("write64_odbc_pooling end FunPid2:~p\n", [FunPid2]),
    io:format("write64_odbc_pooling end FunPid3:~p\n", [FunPid3]),
    io:format("write64_odbc_pooling end FunPid4:~p\n", [FunPid4]),
    io:format("write64_odbc_pooling end FunPid5:~p\n", [FunPid5]),
    {ok}.

write64_epgsql(WsPid, Ballast) ->
    io:format("write64_epgsql\n", []),
    {ok, EpgPool} = application:get_env(cursak, pg_epgsql_pool),
    [{_,_,PropEpgPool}] = EpgPool,
    Hostname = proplists:get_value(hostname_pg, PropEpgPool),
    Database = proplists:get_value(database_pg, PropEpgPool),
    Username = proplists:get_value(username_pg, PropEpgPool),
    Password = proplists:get_value(password_pg, PropEpgPool),
    {ok, ConnectionDescr} = epgsql:connect(Hostname, Username, Password, [{database, Database}]),
    table_init(pg, ConnectionDescr),
    MaxRowsCounter = ?MAX_ROWS_COUNTER,

    FunPid1 =
        spawn(
            fun() -> insert_rows_pg_epg(ConnectionDescr, WsPid, 1, erlang:system_time(), MaxRowsCounter, Ballast)
        end),
    FunPid2 =
        spawn(
            fun() -> insert_rows_pg_epg(ConnectionDescr, WsPid, 2, erlang:system_time(), MaxRowsCounter, Ballast)
        end),
    FunPid3 =
        spawn(
            fun() -> insert_rows_pg_epg(ConnectionDescr, WsPid, 3, erlang:system_time(), MaxRowsCounter, Ballast)
        end),
    FunPid4 =
        spawn(
            fun() -> insert_rows_pg_epg(ConnectionDescr, WsPid, 4, erlang:system_time(), MaxRowsCounter, Ballast)
        end),
    FunPid5 =
        spawn(
            fun() -> insert_rows_pg_epg(ConnectionDescr, WsPid, 5, erlang:system_time(), MaxRowsCounter, Ballast)
        end),

    io:format("write64_epgsql end FunPid1:~p\n", [FunPid1]),
    io:format("write64_epgsql end FunPid2:~p\n", [FunPid2]),
    io:format("write64_epgsql end FunPid3:~p\n", [FunPid3]),
    io:format("write64_epgsql end FunPid4:~p\n", [FunPid4]),
    io:format("write64_epgsql end FunPid5:~p\n", [FunPid5]),
    {ok}.

write64_epgsql_pool(WsPid, Ballast) ->
    io:format("write64_epgsql_pool\n", []),
    table_init(pg, pg_epgsql_pool),
    MaxRowsCounter = ?MAX_ROWS_COUNTER,

    FunPid1 =
        spawn(
            fun() -> insert_rows_pg_pool_epg(pg_epgsql_pool, WsPid, 1, erlang:system_time(), MaxRowsCounter, Ballast)
        end),
    FunPid2 =
        spawn(
            fun() -> insert_rows_pg_pool_epg(pg_epgsql_pool, WsPid, 2, erlang:system_time(), MaxRowsCounter, Ballast)
        end),
    FunPid3 =
        spawn(
            fun() -> insert_rows_pg_pool_epg(pg_epgsql_pool, WsPid, 3, erlang:system_time(), MaxRowsCounter, Ballast)
        end),
    FunPid4 =
        spawn(
            fun() -> insert_rows_pg_pool_epg(pg_epgsql_pool, WsPid, 4, erlang:system_time(), MaxRowsCounter, Ballast)
        end),
    FunPid5 =
        spawn(
            fun() -> insert_rows_pg_pool_epg(pg_epgsql_pool, WsPid, 5, erlang:system_time(), MaxRowsCounter, Ballast)
        end),

    io:format("write64_epgsql_pool end FunPid1:~p\n", [FunPid1]),
    io:format("write64_epgsql_pool end FunPid2:~p\n", [FunPid2]),
    io:format("write64_epgsql_pool end FunPid3:~p\n", [FunPid3]),
    io:format("write64_epgsql_pool end FunPid4:~p\n", [FunPid4]),
    io:format("write64_epgsql_pool end FunPid5:~p\n", [FunPid5]),

    {ok}.

write64_odbc_pool(WsPid, Ballast0) ->
    io:format("write64_odbc_pool\n", []),
    Ballast = erlang:binary_to_list(Ballast0),
    table_init(odbc, pg_odbc_pool),
    MaxRowsCounter = ?MAX_ROWS_COUNTER,

    FunPid1 =
        spawn(
            fun() -> insert_rows_pg_pool_odbc(pg_odbc_pool, WsPid, 1, erlang:system_time(), MaxRowsCounter, Ballast)
        end),
    FunPid2 =
        spawn(
            fun() -> insert_rows_pg_pool_odbc(pg_odbc_pool, WsPid, 2, erlang:system_time(), MaxRowsCounter, Ballast)
        end),
    FunPid3 =
        spawn(
            fun() -> insert_rows_pg_pool_odbc(pg_odbc_pool, WsPid, 3, erlang:system_time(), MaxRowsCounter, Ballast)
        end),
    FunPid4 =
        spawn(
            fun() -> insert_rows_pg_pool_odbc(pg_odbc_pool, WsPid, 4, erlang:system_time(), MaxRowsCounter, Ballast)
        end),
    FunPid5 =
        spawn(
            fun() -> insert_rows_pg_pool_odbc(pg_odbc_pool, WsPid, 5, erlang:system_time(), MaxRowsCounter, Ballast)
        end),

    io:format("write64_epgsql_pool end FunPid1:~p\n", [FunPid1]),
    io:format("write64_epgsql_pool end FunPid2:~p\n", [FunPid2]),
    io:format("write64_epgsql_pool end FunPid3:~p\n", [FunPid3]),
    io:format("write64_epgsql_pool end FunPid4:~p\n", [FunPid4]),
    io:format("write64_epgsql_pool end FunPid5:~p\n", [FunPid5]),

    {ok}.


table_init(odbc, pg_odbc_pool) ->
    pool_pg_odbc:squery(pg_odbc_pool, "DROP TABLE IF EXISTS app_temp_table64_odbc_pool;"),
    pool_pg_odbc:squery(pg_odbc_pool, "CREATE TABLE IF NOT EXISTS app_temp_table64_odbc_pool
        (id SERIAL PRIMARY KEY, create_date timestamp, counter integer, ballast text);");

table_init(odbc, ConnectionDescr) ->
    odbc:sql_query(ConnectionDescr, "DROP TABLE IF EXISTS app_temp_table64_odbc;"),
    odbc:sql_query(ConnectionDescr, "CREATE TABLE IF NOT EXISTS app_temp_table64_odbc
        (id SERIAL PRIMARY KEY, create_date timestamp, counter integer, ballast text);");

table_init(odbc_pooling, ConnectionDescr) ->
    odbc:sql_query(ConnectionDescr, "DROP TABLE IF EXISTS app_temp_table64_odbc_pooling;"),
    odbc:sql_query(ConnectionDescr, "CREATE TABLE IF NOT EXISTS app_temp_table64_odbc_pooling
        (id SERIAL PRIMARY KEY, create_date timestamp, counter integer, ballast text);");

table_init(pg, pg_epgsql_pool) ->
    pool_pg_epgsql:squery(pg_epgsql_pool, <<"DROP TABLE IF EXISTS app_temp_table64_pool ">>),
    pool_pg_epgsql:squery(pg_epgsql_pool, <<"CREATE TABLE IF NOT EXISTS app_temp_table64_pool
        (id SERIAL PRIMARY KEY, create_date timestamp, counter integer, ballast text)">>);

table_init(pg, ConnectionDescr) ->
    epgsql:equery(ConnectionDescr, 
        "DROP TABLE IF EXISTS app_temp_table64 ",[]),
    epgsql:equery(ConnectionDescr, 
        "CREATE TABLE IF NOT EXISTS app_temp_table64 
        (id SERIAL PRIMARY KEY, create_date timestamp, counter integer, ballast text)",[]).


insert_rows_pg_odbc(Connection, WsPid, StreamNumber, StartTime, MaxRowsCounter, Ballast) ->
    io:format("[write64_odbc] {insert_rows} start StreamNumber: ~p\n", [StreamNumber]),
    insert_rows_pg_odbc(Connection, WsPid, StreamNumber, StartTime, MaxRowsCounter, 0, Ballast).

insert_rows_pg_odbc(_, WsPid, StreamNumber, StartTime, MaxRowsCounter, MaxRowsCounter, _) ->
    io:format("[write64_odbc] {insert_rows} end StreamNumber: ~p\n", [StreamNumber]),
    WsPid ! {response2client, #{
        <<"db">> => <<"pg">>,
        <<"lib">> => <<"odbc">>,
        <<"pool">> => false,
        <<"stream_number">> => StreamNumber,
        <<"start_time">> => StartTime,
        <<"end_time">> => erlang:system_time()}},
    ok;
insert_rows_pg_odbc(Connection, WsPid, StreamNumber, StartTime, MaxRowsCounter, RowsCounter, Ballast) ->
    odbc:param_query(Connection,
        "INSERT INTO app_temp_table64_odbc( create_date, counter, ballast) VALUES (now(), ?, ?);",
        [{sql_integer,[RowsCounter]},{{sql_varchar, 100000},[Ballast]}]),
    insert_rows_pg_odbc(Connection, WsPid, StreamNumber, StartTime, MaxRowsCounter, RowsCounter + 1, Ballast).

insert_rows_pg_odbc_pooling(Connection, WsPid, StreamNumber, StartTime, MaxRowsCounter, Ballast) ->
    io:format("[write64_odbc_pooling] {insert_rows} start StreamNumber: ~p\n", [StreamNumber]),
    insert_rows_pg_odbc_pooling(Connection, WsPid, StreamNumber, StartTime, MaxRowsCounter, 0, Ballast).

insert_rows_pg_odbc_pooling(_, WsPid, StreamNumber, StartTime, MaxRowsCounter, MaxRowsCounter, _) ->
    io:format("[write64_odbc_pooling] {insert_rows} end StreamNumber: ~p\n", [StreamNumber]),
    WsPid ! {response2client, #{
        <<"db">> => <<"pg">>,
        <<"lib">> => <<"odbc_pooling">>,
        <<"pool">> => false,
        <<"stream_number">> => StreamNumber,
        <<"start_time">> => StartTime,
        <<"end_time">> => erlang:system_time()}},
    ok;

insert_rows_pg_odbc_pooling(Connection, WsPid, StreamNumber, StartTime, MaxRowsCounter, RowsCounter, Ballast) ->
    odbc:param_query(Connection,
        "INSERT INTO app_temp_table64_odbc_pooling( create_date, counter, ballast) VALUES (now(), ?, ?);",
        [{sql_integer,[RowsCounter]},{{sql_varchar, 100000},[Ballast]}]),
    insert_rows_pg_odbc_pooling(Connection, WsPid, StreamNumber, StartTime, MaxRowsCounter, RowsCounter + 1, Ballast).

insert_rows_pg_pool_epg(pg_epgsql_pool, WsPid, StreamNumber, StartTime, MaxRowsCounter, Ballast) ->
    io:format("[write64_epgsql_pool] {insert_rows} start StreamNumber: ~p\n", [StreamNumber]),
    insert_rows_pg_pool_epg(pg_epgsql_pool, WsPid, StreamNumber, StartTime, MaxRowsCounter, 0, Ballast).

insert_rows_pg_pool_epg(pg_epgsql_pool, WsPid, StreamNumber, StartTime, MaxRowsCounter, MaxRowsCounter, _) ->
    io:format("[write64_epgsql_pool] {insert_rows} end StreamNumber: ~p\n", [StreamNumber]),
    WsPid ! {response2client, #{
        <<"db">> => <<"pg">>,
        <<"lib">> => <<"epgsql">>,
        <<"pool">> => true,
        <<"stream_number">> => StreamNumber,
        <<"start_time">> => StartTime,
        <<"end_time">> => erlang:system_time()}},
    ok;

insert_rows_pg_pool_epg(pg_epgsql_pool, WsPid, StreamNumber, StartTime, MaxRowsCounter, RowsCounter, Ballast) ->
    pool_pg_epgsql:equery(pg_epgsql_pool, 
        "INSERT INTO app_temp_table64_pool( create_date, counter, ballast) VALUES (now(), $1, $2)",
        [RowsCounter, Ballast]),
    insert_rows_pg_pool_epg(pg_epgsql_pool, WsPid, StreamNumber, StartTime, MaxRowsCounter, RowsCounter + 1, Ballast).


insert_rows_pg_pool_odbc(pg_odbc_pool, WsPid, StreamNumber, StartTime, MaxRowsCounter, Ballast) ->
    io:format("[write64_odbc_pool] {insert_rows} start StreamNumber: ~p\n", [StreamNumber]),
    insert_rows_pg_pool_odbc(pg_odbc_pool, WsPid, StreamNumber, StartTime, MaxRowsCounter, 0, Ballast).

insert_rows_pg_pool_odbc(pg_odbc_pool, WsPid, StreamNumber, StartTime, MaxRowsCounter, MaxRowsCounter, _) ->
    io:format("[write64_odbc_pool] {insert_rows} end StreamNumber: ~p\n", [StreamNumber]),
    WsPid ! {response2client, #{
        <<"db">> => <<"pg">>,
        <<"lib">> => <<"odbc">>,
        <<"pool">> => true,
        <<"stream_number">> => StreamNumber,
        <<"start_time">> => StartTime,
        <<"end_time">> => erlang:system_time()}},
    ok;

insert_rows_pg_pool_odbc(pg_odbc_pool, WsPid, StreamNumber, StartTime, MaxRowsCounter, RowsCounter, Ballast) ->
    pool_pg_odbc:equery(pg_odbc_pool, 
        "INSERT INTO app_temp_table64_pool( create_date, counter, ballast) VALUES (now(), $1, $2)",
        [{sql_integer,[RowsCounter]},{{sql_varchar, 100000},[Ballast]}]),
    insert_rows_pg_pool_odbc(pg_odbc_pool, WsPid, StreamNumber, StartTime, MaxRowsCounter, RowsCounter + 1, Ballast).



insert_rows_pg_epg(Connection, WsPid, StreamNumber, StartTime, MaxRowsCounter, Ballast) ->
    io:format("[write64_epgsql] {insert_rows} start StreamNumber: ~p\n", [StreamNumber]),
    insert_rows_pg_epg(Connection, WsPid, StreamNumber, StartTime, MaxRowsCounter, 0, Ballast).

insert_rows_pg_epg(_, WsPid, StreamNumber, StartTime, MaxRowsCounter, MaxRowsCounter, _) ->
    io:format("[write64_epgsql] {insert_rows} end StreamNumber: ~p\n", [StreamNumber]),
    WsPid ! {response2client, #{
        <<"db">> => <<"pg">>,
        <<"lib">> => <<"epgsql">>,
        <<"pool">> => false,
        <<"stream_number">> => StreamNumber,
        <<"start_time">> => StartTime,
        <<"end_time">> => erlang:system_time()}},
    ok;

insert_rows_pg_epg(Connection, WsPid, StreamNumber, StartTime, MaxRowsCounter, RowsCounter, Ballast) ->
    epgsql:equery(Connection, 
        "INSERT INTO app_temp_table64( create_date, counter, ballast) VALUES (now(), $1, $2)",
        [RowsCounter, Ballast]),
    insert_rows_pg_epg(Connection, WsPid, StreamNumber, StartTime, MaxRowsCounter, RowsCounter + 1, Ballast).
