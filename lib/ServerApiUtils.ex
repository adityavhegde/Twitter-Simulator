defmodule ServerApiUtils do
  @spec excrateFromTweet(String.t, integer, String.t) :: list
  def excrateFromTweet(tweetText, index, htOrMention) do
    cond do
      String.length(tweetText) == 0 -> []
      index == String.length(tweetText) - 1 -> []
      String.at(tweetText, index) == htOrMention -> excrateFromTweet(tweetText, index+1, [], "", htOrMention)
      true-> excrateFromTweet(tweetText, index+1, htOrMention)
    end
  end
  @spec  excrateFromTweet(String.t, integer, list, String.t, String.t) :: list
  def excrateFromTweet(tweetText, index, list, acc, htOrMention) do
    cond do
      index == String.length(tweetText) - 1 ->
        cond do
          String.at(tweetText, index) == htOrMention -> list ++ [String.trim(acc)]
          true ->
            acc = acc<>String.at(tweetText, index)
            list ++ [String.trim(acc)]
        end
      String.at(tweetText, index) == htOrMention ->
        list = list ++ [String.trim(acc)]
        excrateFromTweet(tweetText, index+1, list, "", htOrMention)
      true ->
        acc = acc<>String.at(tweetText, index)
        excrateFromTweet(tweetText, index+1, list, acc, htOrMention)
    end
  end
end
