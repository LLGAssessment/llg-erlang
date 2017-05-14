-module(llg).
-export([main/0]).

read_lines() -> read_lines([]).
read_lines(Acc) -> case io:get_line("") of
        eof -> Acc;
        D -> read_lines([D|Acc])
    end.

add_link(Graph, {LeftIdx, LeftWord}, {RightIdx, RightWord}) ->
    LeftLast = lists:last(LeftWord),
    [RightFirst|_] = RightWord,
    if LeftLast == RightFirst ->
        ['$e'|_] = digraph:add_edge(Graph, LeftIdx, RightIdx);
    true ->
        false
    end.

add_links_for_word(_, _, []) -> ok;
add_links_for_word(Graph, LeftWord, [RightWord|Tail]) ->
    add_link(Graph, LeftWord, RightWord),
    add_links_for_word(Graph, LeftWord, Tail).

add_links(Graph, AllWords) -> add_links(Graph, AllWords, AllWords).

add_links(_, _, []) -> ok;
add_links(Graph, AllWords, RemainingWords) ->
    [Word|Tail] = RemainingWords,
    add_links_for_word(Graph, Word, AllWords),
    add_links(Graph, AllWords, Tail).

longest_path(Graph) -> {Path, _} = longest_path(Graph, digraph:vertices(Graph)), Path.

longest_path(Graph, [CV]) -> longest_path_for_vertex(
        Graph,
        CV,
        [],
        0,
        digraph:out_neighbours(Graph, CV));
longest_path(Graph, [CV|Tail]) ->
    { CurPath, CurDepth } = longest_path_for_vertex(
        Graph,
        CV,
        [],
        0,
        digraph:out_neighbours(Graph, CV)),
    { TailPath, TailDepth } = longest_path(Graph, Tail),
    if TailDepth > CurDepth -> {TailPath, TailDepth};
        true -> {CurPath, CurDepth}
    end.

longest_path_for_vertex(
    _,
    Vertex,
    CurPath,
    Depth,
    []
) -> {[Vertex|CurPath], Depth + 1};
longest_path_for_vertex(
    Graph,
    Vertex,
    CurPath,
    Depth,
    [LookupHead|LookupTail]
) ->
    case (lists:member(LookupHead, CurPath) or (Vertex == LookupHead)) of false ->
        {MyPath, MyDepth} = longest_path_for_vertex(
            Graph,
            LookupHead,
            [Vertex|CurPath],
            Depth + 1,
            digraph:out_neighbours(Graph, LookupHead)),
        {OthersPath, OthersDepth} = longest_path_for_vertex(
            Graph,
            Vertex,
            CurPath,
            Depth,
            LookupTail),
        if MyDepth > OthersDepth ->
            {MyPath, MyDepth};
        true ->
            {OthersPath, OthersDepth}
        end;
    true ->
        longest_path_for_vertex(Graph, Vertex, CurPath, Depth, LookupTail)
    end.


main() ->
    Words = lists:usort(lists:filter(
        fun ("") -> false; (_) -> true end,
        lists:map(
            fun (S) -> re:replace(S, "\\s+$|^\\s+", "", [global,{return,list}]) end,
            read_lines()
        )
    )),
    Enumerated =
      lists:zip(lists:seq(1, length(Words)), Words),

    Graph = digraph:new([cyclic, private]),
    lists:map(fun ({Idx, _}) -> digraph:add_vertex(Graph, Idx) end, Enumerated),
    add_links(Graph, Enumerated),
    lists:map(fun(W) -> io:fwrite("~s~n", [lists:nth(W, Words)]) end, lists:reverse(longest_path(Graph))),
    ok.
