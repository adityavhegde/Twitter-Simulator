defmodule ServerApi do
  # contains server logic and functions to be consumed by GenServer
  def tweetSubscribers(userName, tweetText) do
    #TODO send only to users that are connected
    #get client id for given username, get its followers, and send them the tweets
    IO.inspect :ets.lookup(:userPid, userName)
    :ets.lookup(:userPid, userName) 
    |> Enum.at(0) 
    |> elem(1)
    |> Engine.getFollowers() 
    |> Enum.each(fn(pid) ->
      GenServer.cast(pid, tweetText)
    end)
  end

  def tweetMentions(tweetText) do
    #TODO getPid
    tweetText |> ServerApiUtils.getMentions(0) |> Enum.each(fn(userName) ->
      userName |> Engine.getPid() |> GenServer.cast(tweetText)
    end)
  end
end