defmodule ServerApiUtils do
@spec getMentions(String.t, integer) :: list
def getMentions(tweetText, index) do
cond do
String.length(tweetText) == 0 -> []
      index == String.length(tweetText) - 1 -> []
String.at(tweetText, index) == "@" -> getMentions(tweetText, index+1, [], "")
true-> getMentions(tweetText, index+1)
end
end
@spec  getMentions(String.t, integer, list, String.t) :: list
def getMentions(tweetText, index, list, acc) do
cond do
      index == String.length(tweetText) - 1 ->
cond do
String.at(tweetText, index) == "@" -> list ++ [String.trim(acc)]
true ->
            acc = acc<>String.at(tweetText, index)
            list ++ [String.trim(acc)]
end
String.at(tweetText, index) == "@" ->
        list = list ++ [String.trim(acc)]
        getMentions(tweetText, index+1, list, "")
true ->
        acc = acc<>String.at(tweetText, index)
        getMentions(tweetText, index+1, list, acc)
end
end
end