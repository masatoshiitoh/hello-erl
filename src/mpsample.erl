-module(mpsample).

-export([run1/0, run2/0]).

run1() ->
    lists:map(fun(A) -> A * 2 end, [1,2,3,4,5,6,7,8,9,10]).

run2() ->
    RequesterPid = self(),
    lists:map(
        fun(A) -> spawn(fun() -> doubler(RequesterPid, A) end) end,
        [1,2,3,4,5,6,7,8,9,10]),
    receiver2([]).

receiver2(Acc) ->
    receive
        {_A, Result} -> receiver2([Result | Acc])
    after 1000 -> Acc
    end.


doubler(RequesterPid, Number) when is_number(Number) ->
    RequesterPid ! {Number, Number * 2};

doubler(RequesterPid, Payload) ->
    error_logger:error_report({error, doubler, not_number, RequesterPid, Payload, self()}).

