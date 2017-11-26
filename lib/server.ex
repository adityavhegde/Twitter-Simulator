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
  def handle_cast({:subscribe, usernamesToSub, clientPid}, state) do
    # usersToSub is a list of pid's
    usernamesToSub |> Enum.each(fn(username)->
      Engine.subscribe(username, clientPid)
    end)
    {:noreply, state}
  end
  #-----------------------------------------------------------------------------
  # Write and send tweets to subscribers
  def handle_cast({:tweet_subscribers, tweetText, clientId}, state) do
    state = ServerApi.write(state, clientId, tweetText)
    ServerApi.tweetSubscribers(clientId, tweetText)
    ServerApi.tweetMentions(tweetText)
    {:noreply, state}
  end
  #-----------------------------------------------------------------------------
  # Handle search requests by clients
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
end
