defmodule ServerApi do
  @moduledoc """
  Contains server logic and functions to be consumed by GenServer
  """

  @doc """
  Helper function to start a distributed Server Node
  """
  def startNode() do
      nodeFullName = "server@127.0.0.1"
      Node.start (String.to_atom(nodeFullName))
      Node.set_cookie :twitter
      IO.inspect {Node.self, Node.get_cookie}
  end

  @doc """
  Sends a tweet to all the followers of a user
  """
  def tweetSubscribers(userName, tweetText) do
    #TODO send only to users that are connected
    #get client id for given username, get its followers, and send them the tweets
    Engine.getPid(userName)
    |> Engine.getFollowers()
    |> Enum.each(fn(pid) ->
      GenServer.cast(pid, tweetText)
    end)
  end

  @doc """
  Sends a tweet to all the mentions in a tweet
  """
  def tweetMentions(tweetText) do
    tweetText |> EngineUtils.excrateFromTweet(0, "@") |> Enum.each(fn(userName) ->
      userName |> Engine.getPid() |> GenServer.cast(tweetText)
    end)
  end

  #-----------------------------------------------------------------------------
  # Functions for Read and Write actors below

  @doc """
  Helper function used to distribute writes among the 2 Write Actors
  """
  def write(state, clientId, tweetText) do
    {_, indicator_r, indicator, sequenceNum} = state
     [indicator, sequenceNum] =
       cond do
         indicator == 0 ->
           sequenceNum = sequenceNum + 1
           GenServer.cast(:writeActor1, {:write_tweet, clientId, tweetText, sequenceNum})
           [1, sequenceNum]
         true ->
           sequenceNum = sequenceNum + 1
           GenServer.cast(:writeActor2, {:write_tweet, clientId, tweetText, sequenceNum})
           [0, sequenceNum]
       end
    {:running, indicator_r, indicator, sequenceNum}
  end

  @doc """
  Helper functions used to distribute reads among the 2 Read Actors
  """
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
