defmodule ServerApi do
  # contains server logic and functions to be consumed by GenServer
  def tweetSubscribers(userName, tweetText) do
    #TODO send only to users that are connected
    #get client id for given username, get its followers, and send them the tweets
    Engine.getPid(username)
    |> Engine.getFollowers()
    |> Enum.each(fn(pid) ->
      GenServer.cast(pid, tweetText)
    end)
  end

  def tweetMentions(tweetText) do
    tweetText |> ServerApiUtils.excrateFromTweet(0, "@") |> Enum.each(fn(userName) ->
      userName |> Engine.getPid() |> GenServer.cast(tweetText)
    end)
  end

  def write(state, clientId, tweetText) do
    {_, indicator_r, indicator, sequenceNum} = state
     indicator, sequenceNum =
       cond do
         indicator == 0 ->
           sequenceNum = sequenceNum + 1
           GenServer.cast(:writeActor1, {:write_tweet, clientId, tweetText, sequenceNum})
           1, sequenceNum
         true ->
           sequenceNum = sequenceNum + 1
           GenServer.cast(:writeActor2, {:write_tweet, clientId, tweetText, sequenceNum})
           0, sequenceNum
       end
    {:running, indicator_r, indicator, sequenceNum}
  end

  def read(state, {:search, clientId}) do
    {_, indicator_r, indicator_w, sequenceNum} = state
    indicator_r
     = cond do
      indicator_r == 0 ->
        GenServer.cast(:readActor1, {:search, clientId})
        1
      true ->
        GenServer.cast(:readActor2, {:search, clientId})
        0
    end
    {:running, indicator_r, indicator_w, sequenceNum}
  end
  def read(state, {:search_hashtag, clientId, hashtag_list}) do
    {_, indicator_r, indicator_w, sequenceNum} = state
    indicator_r
     = cond do
      indicator_r == 0 ->
        GenServer.cast(:readActor1, {:search_hashtag, clientId, hashtag_list})
        1
      true ->
        GenServer.cast(:readActor2, {:search_hashtag, clientId, hashtag_list})
        0
    end
    {:running, indicator_r, indicator_w, sequenceNum}
  end
  def read(state, {:search_mentions, clientId}) do
    {_, indicator_r, indicator_w, sequenceNum} = state
    indicator_r
     = cond do
      indicator_r == 0 ->
        GenServer.cast(:readActor1, {:search_mentions, clientId})
        1
      true ->
        GenServer.cast(:readActor2, {:search_mentions, clientId})
        0
    end
    {:running, indicator_r, indicator_w, sequenceNum}
  end
end
