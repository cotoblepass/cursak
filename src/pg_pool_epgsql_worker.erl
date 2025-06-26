-module(pg_pool_epgsql_worker).
-behaviour(gen_server).
-behaviour(poolboy_worker).

-export([start_link/1]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2,
         code_change/3]).

-record(state, {conn}).

start_link(Args) ->
    gen_server:start_link(?MODULE, Args, []).

init(Args) ->
    %io:format("Args: ~p",[Args]),
    process_flag(trap_exit, true),
    Hostname = proplists:get_value(hostname_pg, Args),
    Database = proplists:get_value(database_pg, Args),
    Username = proplists:get_value(username_pg, Args),
    Password = proplists:get_value(password_pg, Args),
    {ok, Conn} = epgsql:connect(Hostname, Username, Password, [
        {database, Database}
    ]),
    io:format("Conn: ~p",[Conn]),
    {ok, #state{conn=Conn}}.

handle_call({squery, Sql}, _From, #state{conn=Conn}=State) ->
    {reply, epgsql:squery(Conn, Sql), State};
handle_call({equery, Stmt, Params}, _From, #state{conn=Conn}=State) ->
    {reply, epgsql:equery(Conn, Stmt, Params), State};
handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, #state{conn=Conn}) ->
    ok = epgsql:close(Conn),
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.