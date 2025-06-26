%%%-------------------------------------------------------------------
%% @doc cursak public API
%% @end
%%%-------------------------------------------------------------------

-module(cursak_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_Type, _Args) ->

    Dispatch = cowboy_router:compile([
        %{'_', [{"/", http_handler, []}]}
        {'_', 
            [
                {"/",cowboy_static, {priv_file, cursak,"index.html"}},
                {"/favicon-32x32.png",cowboy_static, {priv_file, cursak,"favicon-32x32.png"}},
                {"/favicon-16x16.png",cowboy_static, {priv_file, cursak,"favicon-16x16.png"}},
                {"/favicon.ico",cowboy_static, {priv_file, cursak,"favicon-16x16.png"}},
                
			    {"/websocket", ws_handler, []}
            ]
        }
    ]),
    {ok, _} = cowboy:start_clear(cursak_http_listener,
        [{port, 8080}],
        #{env => #{dispatch => Dispatch}}
    ),
    cursak_sup:start_link(),
    pool_pg_epgsql:start_link(),
    pool_pg_odbc:start_link(),
    pool_my_mysql:start_link(),
    pool_my_odbc:start_link().

stop(_State) ->
    ok.



%% internal functions
