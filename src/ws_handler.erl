-module(ws_handler).

-export([init/2]).
-export([websocket_init/1]).
-export([websocket_handle/2]).
-export([websocket_info/2]).

init(Req, Opts) ->
	{cowboy_websocket, Req, Opts}.

websocket_init(State) ->
	io:format("websocket_init state: ~p", [State]),
	erlang:start_timer(1000, self(), <<"Hello!">>),
	{[], #{wspid => self()}}.


websocket_handle(Data = {response2client, Msg}, State) ->
	io:format("websocket_handle 0 Data: ~p\n", [Data]),
	io:format("websocket_handle 0 Text: ~p\n", [Msg]),
	WsPid =
		case is_map(State) of
			true ->
				maps:get(wspid, State, null);
			_ ->
				undefined
		end,
	io:format("websocket_handle 0 WsPid: ~p Self():~p", [WsPid, self()]),
	try
		InputData = euneus:decode(Msg),
		io:format("text 0 InputData: ~p\n", [InputData])
		%Result = dispatcher:run(WsPid, InputData)
	catch 
		Error:Reason ->
			io:format("text 0 Error: ~p Reason: ~p\n", [Error, Reason])
	end,
	{[{text, << "text 0 Server echo: ", Msg/binary >>}], State};

websocket_handle({text, Msg}, State) ->

	WsPid =
		case is_map(State) of
			true ->
				maps:get(wspid, State, null);
			_ ->
				undefined
		end,
	io:format("websocket_handle WsPid: ~p Self():~p\n", [WsPid, self()]),
	%Resp = 
		try
			InputData = euneus:decode(Msg),
			io:format("text InputData: ~p\n",
				[
					#{
						<<"action">> => maps:get(<<"action">>, InputData, atsutstvuet),
                  		<<"ballast_size">> => byte_size(maps:get(<<"ballast">>, InputData, atsutstvuet)),
                  		<<"db">> => maps:get(<<"db">>, InputData, atsutstvuet),
						<<"driver">> => maps:get(<<"driver">>, InputData, atsutstvuet),
                  		<<"pool">> => maps:get(<<"pool">>, InputData, atsutstvuet)
					}
				]
			),
			Result = dispatcher:run(WsPid, InputData),
			io:format("text Result: ~p\n", [Result])
		catch 
			Error:Reason ->
				io:format("text Error: ~p Reason: ~p\n", [Error, Reason])
		end,
	%Rresp = 
	{[{text, << "text Server echo: ", Msg/binary >>}], State};
websocket_handle( Data, State) ->
	io:format("Data: ~p", [Data]),
	{[], State}.


websocket_info({response2client, Text}, State) ->
	io:format("websocket_info response2client Text: ~p\n", [Text]),
	Text2 = euneus:encode(Text),
	io:format("websocket_info response2client Text2: ~p\n", [Text2]),
    {[{text, Text2}], State};
websocket_info({data, Text}, State) ->
	io:format("websocket_info data Text: ~p\n", [Text]),
    {[{text, Text}], State};
websocket_info({log, Text}, State) ->
	io:format("websocket_info log Text: ~p\n", [Text]),
    {[{text, Text}], State};

websocket_info(_Info, State) ->
	{[], State}.