defmodule Engine do
  @moduledoc """
  This module creates various ets tables for the application. It also comes
  with various functions to deal with these tables.

  We have the following tables for our application
  users - user_id (key), username, followers | mapping of a clientPid and client's alias
  following - user_id (key), listOfPeopleIFollow | a list of people I follow
  tweets - user_id (key), [[tweet_id, tweetText]] | contains tweet data.
           Tweets are a list of lists. Each element is a tweet
  hashtag - hashtag (key), [[tweet_id, tweetText]] | quick access of tweets for a given hashtag
  userPid - username (key), pid | mapping of username and pid
  userMentions - user_id (key), [[tweet_id, tweetText]]
           A list of tweets where a user is mentioned

  Types -
  user_id: pid
  username: String.t
  followers: pid | a list of user_id's followers
  listOfPeopleIFollow: list of pid's
  tweet_id: number | a sequence number, used in place of a timestamp
  hashtag: String.t
  """
  use GenServer

  #function to initialize in-memory tables
  def initTables do
    #initialize all tables. See moduledoc for details
    :ets.new(:users, [:set, :public, :named_table])
    :ets.new(:following, [:set, :public, :named_table])
    :ets.new(:tweets, [:set, :public, :named_table])
    :ets.new(:hashtag, [:set, :public, :named_table])
    :ets.new(:userPid, [:set, :public, :named_table])
    :ets.new(:userMentions, [:set, :public, :named_table])
  end

  #userName is client's PID
  def register(clientPid, userName) do
    :ets.insert_new(:users, {clientPid, userName, []})
    :ets.insert_new(:userPid, {userName, clientPid})
  end

  @doc """
  Subscribe the clientPid to the userToSubPid
  Upon subscription, the clientPid becomes a follower of userToSubPid

  The userToSubPid is also added to clientPid's 'list of people I follow'
  This association is made by also inserting in the :following table
  """
  #TODO userToSubPid can be changed to userName, just as it would happen in a normal tweet
  def subscribe(userToSubPid, clientPid) do
    [{userToSubPid, userName, followers}] = :ets.lookup(:users, userToSubPid)
    followers = followers ++ [clientPid]
    :ets.insert(:users, {userToSubPid, userName, followers})

    # also insert in the :following table
    toFollow = cond do
      :ets.member(:following, clientPid) ->
        [{_, listOfPeopleIFollow}] = :ets.lookup(:following, clientPid)
        listOfPeopleIFollow = listOfPeopleIFollow ++ [userToSubPid]
      true -> [userToSubPid]
    end
    :ets.insert(:following, {clientPid, toFollow})
  end

  @doc """
  Takes as input a clientPid, tweetText contaning hashtag and mentions, a sequenceNum
  Makes an insertion in - tweets, hashtag, userMentions
  """
  def writeTweet(clientPid, tweetText, sequenceNum) do
    tweet = cond do
      :ets.member(:tweets, clientPid) ->
        [{_, tweet_list}] = :ets.lookup(:tweets, clientPid)
        tweet_list ++ [[sequenceNum, tweetText]]
      true ->
        [[sequenceNum, tweetText]]
    end
    :ets.insert(:tweets, {clientPid, tweet})

    # insertion into the hashtag table
    ServerApiUtils.excrateFromTweet(tweetText, 0, "#")
      |> Enum.each(fn(hashtag) ->
          tweet = cond do
            :ets.member(:hashtag, hashtag) ->
              [{_, tweet_list}] = :ets.lookup(:hashtag, hashtag)
              tweet_list ++ [[sequenceNum, tweetText]]
            true -> [[sequenceNum, tweetText]]
          end
          :ets.insert(:hashtag, {hashtag, tweet})
      end)

    # insertion into the userMentions table
    ServerApiUtils.excrateFromTweet(tweetText, 0, "@")
      |> Enum.each(fn(mention)->
        mention = EngineUtils.mentionToPid(mention)
        tweet = cond do
          :ets.member(:userMentions, mention) ->
            [{_, tweet_list}] = :ets.lookup(:userMentions, mention)
            tweet_list ++ [[sequenceNum, tweetText]]
          true -> [[sequenceNum, tweetText]]
        end
        :ets.insert(:userMentions, {mention, tweet})
    end)
  end

  #----------------------------------------------------------------------------
  # Below: functions that only read from database
  # Do not add write functions

  @doc """
  Returns a list of pid's of followers for a given pid
  """
  @spec getFollowers(pid) :: list
  def getFollowers(userPid) do
    [{_, _, follower_list}] = :ets.lookup(:users, userPid)
    follower_list
  end

  @doc """
  Returns a list of pid's of all the users, a pid is following
  """
  @spec getFollowing(pid) :: list
  def getFollowing(clientPid) do
    [{_, peopleIFollow}] = :ets.lookup(:following, clientPid)
    peopleIFollow
  end

  @doc """
  Returns the pid, given a username
  """
  @spec getPid(String.t) :: pid
  def getPid(userName) do
    [{_, pid}] = :ets.lookup(:userPid, userName)
    pid
  end

  @doc """
  Returns all the tweets of a given pid (user/client)
  """
  @spec getTweets(pid) :: list
  def getTweets(clientPid) do
    #TODO sort tweets based on sequence number in descending order
    [{_, tweet_list}]= :ets.lookup(:tweets, clientPid)
    tweet_list
  end

  @doc """
  Usage: getTweetHavingHashtag
  Pass a hashtag to get a list in return as below
  hashtag = "studentLife"
  [tweetText1, tweetText2] = Engine.getTweetHavingHashtag(hashtag)
  TODO Returned list is sorted based on sequence number (desc)
  """
  @spec getTweetsHavingHashtag(String.t) :: list
  def getTweetsHavingHashtag(hashtag) do
    #TODO do the sorting of tweets
    [{_, tweet_list}] = :ets.lookup(:hashtag, hashtag)
    tweet_list
  end

  @doc """
  Returns a list of tweets where a pid has been mentioned
  """
  @spec getMentions(pid) :: list
  def getMentions(clientPid) do
    #TODO sorting tweets
    [{_, tweet_list}] = :ets.lookup(:userMentions, clientPid)
    tweet_list
  end
 end

defmodule EngineUtils do
  @moduledoc """
  Utility functions for Engine module
  """

  @doc """
  Turns a mention into a pid
    eg: mention = '<0.81.0>'
    mention |> EngineUtils.mentionToPid
    This transforms the mention into a pid - #PID<0.81.0>
  Warning: :erlang.list_to_pid should only be used for debugging purposes
    This dependency should be removed in future version
  """
  @spec mentionToPid(String.t) :: pid
  def mentionToPid(mention) do
    :erlang.list_to_pid('#{mention}')
  end
end
