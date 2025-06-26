-module(dispatcher).

-export([run/2]).


run(WsPid, #{<<"action">> := <<"init">>, <<"db">> := <<"postgres">>, <<"ballast">> := Ballast}) ->
    io:format("dispatcher ClientDate: ~p",[Ballast]),
    WsPid ! {response2client, Ballast};
run(WsPid, #{<<"action">> := <<"init">>, <<"db">> := <<"mysql">>, <<"ballast">> := Ballast}) ->
    WsPid ! {response2client, Ballast};

run(WsPid, #{<<"action">> := <<"run">>, <<"db">> := <<"postgres">>,
        <<"pool">> := false, <<"driver">> := <<"odbc">>, <<"ballast">> := Ballast}) ->
            {ok} = pg:write64_odbc(WsPid, Ballast),
            io:format("dispatcher end \n", []),
            {ok};

run(WsPid, #{<<"action">> := <<"run">>, <<"db">> := <<"postgres">>,
        <<"pool">> := false, <<"driver">> := <<"odbc_pooling">>, <<"ballast">> := Ballast}) ->
            {ok} = pg:write64_odbc_pooling(WsPid, Ballast),
            io:format("dispatcher end \n", []),
            {ok};

run(WsPid, #{<<"action">> := <<"run">>, <<"db">> := <<"postgres">>,
        <<"pool">> := false, <<"driver">> := <<"epgsql">>, <<"ballast">> := Ballast}) ->
            {ok} = pg:write64_epgsql(WsPid, Ballast),
            io:format("dispatcher end \n", []),
            {ok};
run(WsPid, #{<<"action">> := <<"run">>, <<"db">> := <<"postgres">>,
        <<"pool">> := true, <<"driver">> := <<"odbc">>, <<"ballast">> := Ballast}) ->
            {ok} = pg:write64_odbc_pool(WsPid, Ballast),
            io:format("dispatcher end \n", []),
            {ok};
run(WsPid, #{<<"action">> := <<"run">>, <<"db">> := <<"postgres">>,
        <<"pool">> := true, <<"driver">> := <<"epgsql">>, <<"ballast">> := Ballast}) ->
            {ok} = pg:write64_epgsql_pool(WsPid, Ballast),
            io:format("dispatcher end \n", []),
            {ok};
run(WsPid, #{<<"action">> := <<"run">>, <<"db">> := <<"mysql">>,
        <<"pool">> := false, <<"driver">> := <<"odbc">>, <<"ballast">> := Ballast}) ->
            my:write64_my_odbc(WsPid, Ballast),
            io:format("dispatcher end \n", []),
            {ok};

run(WsPid, #{<<"action">> := <<"run">>, <<"db">> := <<"mysql">>,
        <<"pool">> := false, <<"driver">> := <<"mysql">>, <<"ballast">> := Ballast}) ->
            my:write64_my_mysql(WsPid, Ballast),
            io:format("dispatcher end \n", []),
            {ok};

run(WsPid, #{<<"action">> := <<"run">>, <<"db">> := <<"mysql">>,
        <<"pool">> := true, <<"driver">> := <<"odbc">>, <<"ballast">> := Ballast}) ->
            my:write64_my_odbc_pool(WsPid, Ballast),
            io:format("dispatcher end \n", []),
            {ok};
run(WsPid, #{<<"action">> := <<"run">>, <<"db">> := <<"mysql">>,
        <<"pool">> := false, <<"driver">> := <<"odbc_pooling">>, <<"ballast">> := Ballast}) ->
            my:write64_my_odbc_pooling(WsPid, Ballast),
            io:format("dispatcher end \n", []),
            {ok};
run(WsPid, #{<<"action">> := <<"run">>, <<"db">> := <<"mysql">>,
        <<"pool">> := true, <<"driver">> := <<"mysql">>, <<"ballast">> := Ballast}) ->
            my:write64_my_mysql_pool(WsPid, Ballast),
            io:format("dispatcher end \n", []),
            {ok}.