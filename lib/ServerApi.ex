defmodule ServerApi do
  @spec getMentions(String.t) :: list
  def getMentions(tweetText) do
    # cases start with mention and reach the end of string
    # starts with mention and reaches a string
    # starts with a mention and reaches another mention
    
  end
  def getMentions(tweetText, "@") do

  end
  def getMentions(tweetText, mention) do

  end

  def tweetSubscribers(clientId, tweetText) do
    clientId |> Engine.getFollowers() |> Enum.each(fn(pid) ->
      GenServer.cast(pid, tweetText)
    end)
  end

  def tweetMentions(clientId, tweetText) do
    tweetText |> getMentions() |> Enum.each(fn(pid) ->
      GenServer.cast(pid, tweetText)
    end)
  end
end
