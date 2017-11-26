defmodule Server do
  use GenServer
  def handle_call(:start, from, state) do
    TwitterHelper.startNode
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

defmodule Project4 do
  use GenServer
  def main(args) do
    role = args
            |> parse_args
            |> Enum.at(0)

    cond do
      role == "server" ->
        indicator_r = 0
        indicator_w = 0
        sequenceNum = 0
        state = {:running, indicator_r, indicator_w, sequenceNum}
        {:ok, pid} = GenServer.start(Server, state, name: :server)
        GenServer.call(:server, :start, :infinity)
      role == "simulator" ->
        numClients = args
                    |> parse_args
                    |> Enum.at(1)
                    |> Integer.parse(10)
                    |> elem(0)
        actorsPid = Simulator.start(numClients)
        Simulator.subscribe(actorsPid)
        Simulator.sendTweet(actorsPid)
      true ->
        true
    end

    #send self, :checkAlive
    #:timer.apply_interval(:timer.seconds(1), __MODULE__, :checkAlive, [])
    receive do
      :test ->
        IO.puts "test"
    end
  end

  def checkAlive do
    IO.inspect Node.alive?
  end

  #parsing the input argument
  defp parse_args(args) do
    {_, word, _} = args
    |> OptionParser.parse(strict: [:string, :integer, :string])
    word
  end
end
