defmodule ServerApi do
  def getMentions(tweetText, index) do
    cond do
      String.length(tweetText) == 0 -> []
      index == String.length(tweetText) - 1 -> []
      String.at(tweetText, index) == "@" -> getMentions(tweetText, index+1, [], "")
      true-> getMentions(tweetText, index+1)
    end
  end
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

  def tweetSubscribers(clientId, tweetText) do
    clientId |> Engine.getFollowers() |> Enum.each(fn(pid) ->
      GenServer.cast(pid, tweetText)
    end)
  end

  def tweetMentions(clientId, tweetText) do
    tweetText |> getMentions() |> Enum.each(fn(userName) ->
      userName |> Engine.getPid() |> GenServer.cast(tweetText)
    end)
  end
end
