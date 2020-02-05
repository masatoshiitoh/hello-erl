-module(mpsample).

-export([run1/0, run2/0]).

%% run1は、リスト操作でリストの値を2倍にしている
run1() ->
    lists:map(fun(A) -> A * 2 end, [1,2,3,4,5,6,7,8,9,10]).

%% run2は、リストの要素1つ1つにプロセスを起動している
run2() ->
    RequesterPid = self(),
    %% プロセス生成
    lists:map(
        fun(A) -> spawn(fun() -> doubler(RequesterPid, A) end) end,
        [1,2,3,4,5,6,7,8,9,10]),
    %% 受信処理
    receiver2([]).

%% タイムアウトするまで受信してリストに格納し続ける
receiver2(Acc) ->
    receive
        {_A, Result} -> receiver2([Result | Acc])
    after 1000 -> Acc
    end.

%% 指定のプロセスに計算結果をメッセージ送信する（数値のときだけ）
doubler(RequesterPid, Number) when is_number(Number) ->
    RequesterPid ! {Number, Number * 2};

%% 上記の条件（数値のときだけ）に合致しないときに実行されるdoubler関数
doubler(RequesterPid, Payload) ->
    error_logger:error_report({error, doubler, not_number, RequesterPid, Payload, self()}).
