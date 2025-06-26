-module(pool_pg_epgsql).
%-behaviour(application).
-behaviour(supervisor).

-export([start_link/0]).

-export([init/1]).
-export([ squery/2, equery/3]).

-define(SERVER, ?MODULE).

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

init([]) ->
    {ok, Pools} = application:get_env(cursak, pg_epgsql_pool),
    PoolSpecs = lists:map(fun({Name, SizeArgs, WorkerArgs}) ->
        PoolArgs = [{name, {local, Name}},
            		{worker_module, pg_pool_epgsql_worker}] ++ SizeArgs,
        poolboy:child_spec(Name, PoolArgs, WorkerArgs)
    end, Pools),
    {ok, {{one_for_one, 10, 10}, PoolSpecs}}.

squery(PoolName, Sql) ->
    %io:format("++++++++++++++++++++++++++squery PoolName: ~p Sql: ~p", [PoolName, Sql]),
    poolboy:transaction(PoolName, fun(Worker) ->
        %io:format("++++++++++++++++++++++++++squery PoolName: ~p Sql: ~p State: ~p", [PoolName, Sql, State]),
        gen_server:call(Worker, {squery, Sql})
    end).

equery(PoolName, Stmt, Params) ->
    poolboy:transaction(PoolName, fun(Worker) ->
        gen_server:call(Worker, {equery, Stmt, Params})
    end).