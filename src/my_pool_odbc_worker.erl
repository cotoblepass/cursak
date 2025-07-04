-module(my_pool_odbc_worker).
-behaviour(gen_server).
-behaviour(poolboy_worker).

-export([start_link/1]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2,
         code_change/3]).

-record(state, {conn}).

start_link(Args) ->
    gen_server:start_link(?MODULE, Args, []).

init(Args) ->
    process_flag(trap_exit, true),
    OdbcConnString  = 
        case proplists:get_value(odbc_my, Args) of
            Value when is_list(Value) ->
                Value;
            Value when is_binary(Value) ->
                binary_to_list(Value)
        end,
    {ok, Conn} = odbc:connect(OdbcConnString,[]),
    {ok, #state{conn=Conn}}.



handle_call({squery, Sql}, _From, #state{conn=Conn}=State) ->
    {reply, odbc:sql_query(Conn, Sql), State};
handle_call({equery, Stmt, Params}, _From, #state{conn=Conn}=State) ->
    {reply, odbc:param_query(Conn, Stmt, Params), State};
handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, #state{conn=Conn}) ->
    ok = odbc:disconnect(Conn).

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
