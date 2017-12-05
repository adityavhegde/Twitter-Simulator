defmodule TweetActors do
  @moduledoc """
  This is an Actor to handle the incoming tweets to the Server
  The Server distributes the work of sending tweets among many such TweetActors
  """
  use GenServer

  @doc """
  Sends a tweet to the followers of a user
  Also sends the tweet to the mentions inside a tweet
  """
  def handle_cast({:tweet_subscribers, userPid, tweet_time, tweetText}, state) do
    userPid
    |> Engine.getFollowers()
    |> Enum.filter(fn(pid) ->
        Engine.isLoggedIn(pid) == true
      end)
    |> Enum.each(fn(pid) ->
      GenServer.cast(pid, {:receiveTweet, tweet_time, tweetText})
    end)
    {:noreply, state}
  end

  def init(state) do
    {:ok, state}
  end
end
