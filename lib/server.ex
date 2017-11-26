defmodule Server do
  @moduledoc """
  Module to handle all the calls to the Server
  """
  use GenServer
  def handle_call(:start, from, state) do
    ServerApi.startNode()
    #Engine.startServer
    Engine.initTables
    {:reply, :started, state}
  end
  #handle call for registering a new process,
  #needs to be handle call only since can't tweet until registered
  def handle_call({:register, userName}, clientPid, state) do
    #IO.puts "registering client"
    #IO.inspect clientPid |> elem(0)
    Engine.register(clientPid |> elem(0), userName)
    {:reply, :registered, state}
  end
  #handle_cast to subscribe client to a user
  def handle_cast({:subscribe, usersToSub, clientPid}, state) do
    # usersToSub is a list of pid's
    usersToSub |> Enum.each(fn(userPid)->
      Engine.subscribe(userPid, clientPid)
    end)
    {:noreply, state}
  end

  #
  def handle_cast({:tweet_subscribers, tweetText, userName}, state) do
    #IO.inspect :ets.lookup(:users, clientId)
    ServerApi.tweetSubscribers(userName, tweetText)
    ServerApi.tweetMentions(tweetText)
    {:noreply, state}
  end

  def handle_call(:getUsers, from, state) do
    userNames = Server.keys(:users)
    {:reply, userNames, state}
  end
  def handle_cast({:tweet_subscribers, tweetText, clientId}, state) do
    state = ServerApi.write(state, clientId, tweetText)
    ServerApi.tweetSubscribers(clientId, tweetText)
    ServerApi.tweetMentions(tweetText)
    {:noreply, state}
  end
  def handle_cast({:search, clientId}, state) do
    state = ServerApi.read(state, {:search, clientId})
    {:noreply, state}
  end
  def handle_cast({:search_hashtag, clientId, hashtag_list}, state) do
    state = ServerApi.read(state, {:search_hashtag, clientId, hashtag_list})
    {:noreply, state}
  end
  def handle_cast({:search_mentions, clientId}, state) do
    state = ServerApi.read(state, {:search_mentions, clientId})
    {:noreply, state}
  end
  def init(state) do
    GenServer.start(ReadTweets, :running, name: :readActor1)
    GenServer.start(ReadTweets, :running, name: :readActor2)
    GenServer.start(WriteTweet, :running, name: :writeActor1)
    GenServer.start(WriteTweet, :running, name: :writeActor2)
    {:ok, state}
  end
end
