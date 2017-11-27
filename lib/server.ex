defmodule Server do
  @moduledoc """
  Module to handle all the calls to the Server
  """
  use GenServer

  def init(state) do
    GenServer.start(ReadTweets, :running, name: :readActor1)
    GenServer.start(ReadTweets, :running, name: :readActor2)
    GenServer.start(WriteTweet, :running, name: :writeActor1)
    GenServer.start(WriteTweet, :running, name: :writeActor2)
    {:ok, state}
  end

  def handle_call(:start, from, state) do
    ServerApi.startNode()
    Engine.initTables()
    {:reply, :started, state}
  end
  # handle call for registering a new process,
  # needs to be handle call only since can't tweet until registered
  def handle_call({:register, userName}, clientPid, state) do
    Engine.register(clientPid |> elem(0), userName)
    {:reply, :registered, state}
  end
  # handle_cast to subscribe user/client to another user/client
  def handle_call({:subscribe, usersToSub}, clientPid, state) do
    {clientPid, _} = clientPid
    # usersToSub is a list of pid's
    usersToSub |> Enum.each(fn(userName)->
      userPid = Engine.getPid(userName)
      Engine.subscribe(userPid, clientPid)
    end)
    {:reply, {:subscribed}, state}
  end
  #-----------------------------------------------------------------------------
  # Write and send tweets to subscribers
  def handle_cast({:tweet_subscribers, tweetText, userName}, state) do
    clientId = Engine.getPid(userName)
    #state = ServerApi.write(state, clientId, tweetText)
    ServerApi.tweetSubscribers(clientId, tweetText)
    ServerApi.tweetMentions(tweetText)
    {:noreply, state}
  end
  #-----------------------------------------------------------------------------
  # Handle search requests by clients
  def handle_cast({:search, userName}, state) do
    IO.puts "searching for tweets"
    clientId = Engine.getPid(userName)
    state = ServerApi.read(state, {:search, clientId})
    {:noreply, state}
  end
  def handle_cast({:search_hashtag, userName, hashtag_list}, state) do
    clientId = Engine.getPid(userName)
    state = ServerApi.read(state, {:search_hashtag, clientId, hashtag_list})
    {:noreply, state}
  end
  def handle_cast({:search_mentions, userName}, state) do
    clientId = Engine.getPid(userName)
    state = ServerApi.read(state, {:search_mentions, clientId})
    {:noreply, state}
  end
end