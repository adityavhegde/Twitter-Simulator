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
  def handle_cast({:subscribe, usersToSubPid, clientPid}, state) do
    Enum.each(usersToSubPid, fn(userPid) ->
      Engine.subscribe(userPid, clientPid)
    end)
    #IO.inspect :ets.lookup(:users, clientPid)
    #IO.inspect :ets.lookup(:following, clientPid)
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

  def init(state) do
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
        state = :running
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
