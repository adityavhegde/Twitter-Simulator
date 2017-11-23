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
  def handle_cast({:subscribe, userToSub, clientPid}, state) do
    Engine.subscribe(userToSub, clientPid)
    {:noreply, state}
  end
  def handle_call(:getUsers, from, state) do
    userNames = Server.keys(:users)
    {:reply, userNames, state}
  end
  def handle_cast({:tweet_subscribers, tweetText, clientId}, state) do
    ServerApi.tweetSubscribers(clientId, tweetText)
    ServerApi.tweetMentions(tweetText)
    {:noreply, state}
  end

  def init(state) do
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
        state = :running
<<<<<<< HEAD
=======
        TwitterHelper.startNode
>>>>>>> server
        {:ok, pid} = GenServer.start(Server, state, name: :server)
        GenServer.call(:server, :start, :infinity)
        #IO.inspect Process.alive?(pid)
      role == "client" ->
<<<<<<< HEAD
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
=======
        Node.start :"client@192.168.0"
        Node.set_cookie :xyzzy
        Node.connect "server@192.168.0.17"
        #Client.start
>>>>>>> server
      true ->
        true
    end

<<<<<<< HEAD
    #IO.inspect Process.alive?(pid)
=======
>>>>>>> server
    receive do
      :test ->
        IO.puts "test"
    end
  end

  #parsing the input argument
  defp parse_args(args) do
<<<<<<< HEAD
    {_, word, _} = args
    |> OptionParser.parse(strict: [:string, :integer, :string])
=======
    {_, word, _} = args
    |> OptionParser.parse(strict: [:integer, :string, :string])
>>>>>>> server
    word
  end
end
