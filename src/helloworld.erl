-module(helloworld).

-export([run_sample/0]).

run_sample() ->
    Pid = spawn(fun() -> doubler() end),
    Pid ! {calc, self(), 12},
    receive
        R1 ->
            io:format ("return ~p~n", [R1])
        after 1000 ->
            io:format ("first receiver timed out~n", [])
    end,

    Pid ! {unknown, self(), "GEEEEE!"},
    receive
        R2 ->
            io:format ("return ~p~n", [R2])
        after 1000 ->
            io:format ("second receiver timed out~n", [])
    end,

    Pid ! stop,
    receive
        R3 ->
            io:format ("return ~p~n", [R3])
        after 1000 ->
            io:format ("third receiver timed out~n", [])
    end,
    0.

doubler() ->
    receive
        {calc, Pid, Number} ->
            Pid ! Number * 2,
            doubler();
        stop ->
            error_logger:error_report({self(), "stop requested. bye."}),
            0;
        Unknown -> 
            error_logger:error_report({self(), unknown_message, Unknown}),
            doubler()
    end.
    

