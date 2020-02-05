-module(helloworld).

-export([run_sample/0]).

run_sample() ->
    %% doubler関数をプロセスとして起動する
    Pid = spawn(fun() -> doubler() end),

    %% doublerが受け取れる書式で 12 を送付
    Pid ! {calc, self(), 12},
    receive
        R1 ->
            io:format ("return ~p~n", [R1])
        after 1000 ->
            io:format ("first receiver timed out~n", [])
    end,

    %% doublerが受け取れない書式のメッセージ
    Pid ! {unknown, self(), "GEEEEE!"},
    receive
        R2 ->
            io:format ("return ~p~n", [R2])
        after 1000 ->
            io:format ("second receiver timed out~n", [])
    end,

    %% doublerに終了指示
    Pid ! stop,
    receive
        R3 ->
            io:format ("return ~p~n", [R3])
        after 1000 ->
            io:format ("third receiver timed out~n", [])
    end,
    0.

%% メッセージで送られてきた値を2倍にして返す
%% 実行し続けるために末尾再帰している
doubler() ->
    receive
        {calc, Pid, Number} ->
            %% メッセージ
            Pid ! Number * 2,
            doubler();
        stop ->
            %% 停止メッセージが来たら、ログを出力して終了
            error_logger:error_report({self(), "stop requested. bye."}),
            0;
        Unknown ->
            %% それ以外のメッセージが来たらエラー報告
            error_logger:error_report({self(), unknown_message, Unknown}),
            doubler()
    end.
    

