defmodule ServerApi do
  # contains server logic and functions to be consumed by GenServer
  def tweetSubscribers(clientId, tweetText) do
    #TODO send only to users that are connected
    clientId |> Engine.getFollowers() |> Enum.each(fn(pid) ->
      GenServer.cast(pid, tweetText)
    end)
  end

  def tweetMentions(tweetText) do
    tweetText |> ServerApiUtils.getMentions(0) |> Enum.each(fn(userName) ->
      userName |> Engine.getPid() |> GenServer.cast(tweetText)
    end)
  end
end
