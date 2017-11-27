defmodule ReadTweets do
  @moduledoc """
  This is an Actor to handle incoming search requests
  The main Server delegates search queries to this Actor

  """
  use GenServer

  @doc """
  This method sends a timeline of tweets to the requestor
  These tweets are the tweets of a user that the clientId subscribes to
  """
  def handle_cast({:search, clientId}, state) do
    Engine.getFollowing(clientId) |> Enum.each(fn(person_i_follow) ->
      Engine.getTweets(person_i_follow) |> Enum.each(fn(tweet) ->
        # tweet -> [tweet_id, tweetText]
        # TODO turns into just a list of tweetTexts after sorting
        GenServer.cast(clientId, {:search_result, Enum.at(tweet, 1)})
      end)
    end)
    {:noreply, state}
  end

  @doc """
  This method sends a timeline of tweets that contain specific hashtags
  """
  def handle_cast({:search_hashtag, clientId, hashtag_list}, state) do
    Enum.each(hashtag_list, fn(hashtag)->
      Engine.getTweetsHavingHashtag(hashtag) |> Enum.each(fn(tweet) ->
        # tweet -> [tweet_id, tweetText]
        # TODO turns into just a list of tweetTexts after sorting
        GenServer.cast(clientId, {:search_result_ht, Enum.at(tweet, 1)})
      end)
    end)
    {:noreply, state}
  end

  @doc """
  This method sends a timeline of tweets to the requestor
  These tweets are the tweets where the user is mentioned
  """
  def handle_cast({:search_mentions, clientId}, state) do
    # TODO create a hashtag table that contains {mention, [{tweet, tweet_id}, ..n]}
    clientId |> Engine.getMentions() |> Enum.each(fn(tweet) ->
      # tweet -> [tweet_id, tweetText]
      # TODO turns into just a list of tweetTexts after sorting
      GenServer.cast(clientId, {:search_result_mention, Enum.at(tweet, 1)})
    end)
    {:noreply, state}
  end

  def init(state) do
    {:ok, state}
  end
end
