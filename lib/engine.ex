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

  #subscribe to a user
  #TODO userToSubPid can be changed to userName, just as it would happen in a normal tweet
  def subscribe(userToSubPid, clientPid) do
    [{userToSubPid, userName, followers}] = :ets.lookup(:users, userToSubPid)
    followers = followers ++ [clientPid]
    :ets.insert(:users, {userToSubPid, userName, followers})

    # also insert in the following table
    [{_, listOfPeopleIFollow}] = :ets.lookup(:following, clientPid)
    listOfPeopleIFollow = listOfPeopleIFollow ++ [userToSubPid]
    :ets.insert(:following, {clientPid, listOfPeopleIFollow})
  end

  def writeTweet(clientPid, tweet) do
    #TODO finish This
    #TODO how to maintain sequence_num -> mostly on main server process
    #TODO write a function to extract hashtags and make an insert in hashtag table
    #TODO also make an insert in the mentions table
  end

  #----------------------------------------------------------------------------
  # Below: functions that only read from database
  # Do not add write functions
  @spec getFollowers(pid) :: list
  def getFollowers(userPid) do
    :ets.lookup(:users, userPid) |> Enum.at(0) |> elem(2)
  end

  @spec getFollowing(pid) :: list
  def getFollowing(clientPid) do
    :ets.lookup(:following, clientPid) |> Enum.at(0) |> elem(1)
  end

  @spec getPid(String.t) :: pid
  def getPid(userName) do
    :ets.lookup(:userPid, userName) |> Enum.at(0) |> elem(1)
  end

  @spec getTweets(pid) :: list
  def getTweets(clientPid) do
    #TODO sort tweets based on sequence number in descending order
    :ets.lookup(:tweets, clientPid)
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
    :ets.lookup(:hashtag, hashtag)
  end

  @spec getMentions(pid) :: list
  def getMentions(clientPid) do
    #TODO sorting tweets
    :ets.lookup(:userMentions, clientPid)
  end
 end

defmodule EngineUtils do
  @moduledoc """
  Utility functions for Engine module
  """

end
