defmodule WriteTweet do
  @moduledoc """
  This is an actor that handles the writes to database
  When a user tweets, the tweet is written to the tweet ets table

  The main server process delegates writes to the Actor
  """
  use GenServer

  @doc """
  Writes a tweet. A tweet contains hashtags, mentions and the tweet text; each
  having their own ets table.
  """
  def handle_cast({:write_tweet, clientId, tweetText, sequenceNum}, state) do
    Engine.writeTweet(clientId, tweetText, sequenceNum)
    {:noreply, state}
  end

  def init(state) do
    {:ok, state}
  end
end
