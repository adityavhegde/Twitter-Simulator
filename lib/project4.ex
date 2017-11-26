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
    IO.puts "registering client"
    Engine.register(clientPid, userName)
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
  def main(args) do
    role = args
            |> parse_args
            |> Enum.at(0)

    numClients = cond do
      role == "client" ->
        args
        |> parse_args
        |> Enum.at(1)
        |> Integer.parse(10)
        |> elem(0)
      true ->
        0
    end

    cond do
      role == "server" ->
        indicator_r = 0
        indicator_w = 0
        sequenceNum = 0
        state = {:running, indicator_r, indicator_w, sequenceNum}
        {:ok, pid} = GenServer.start(Server, state, name: :server)
        GenServer.call(:server, :start, :infinity)
        #IO.inspect Process.alive?(pid)
      role == "client" ->
        state = :running
        #Simulator.startClientNode
        nodeName = "client@127.0.0.1"
        Node.start String.to_atom(nodeName)
        Node.set_cookie :twitter
        Node.connect :"server@127.0.0.1"
        {:ok, pid} = GenServer.start(Simulator, state, name: :simulator)
        GenServer.cast(:simulator, numClients)
        #{:ok, pid} = GenServer.start(Client, state)
        #GenServer.call(pid, :register, :infinity)
        #IO.inspect Process.alive?(pid)
        #Client.start
        #Client.subscribe
      true ->
        true
    end

    receive do
      :test ->
        IO.puts "test"
    end
  end

  #parsing the input argument
  defp parse_args(args) do
    {_, word, _} = args
    |> OptionParser.parse(strict: [:string, :integer, :string])
    word
  end
end
