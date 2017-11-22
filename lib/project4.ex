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
  def handle_call(:register, clientPid, state) do
    IO.puts "registering client"
    Engine.register(clientPid)
    {:reply, :registered, state}
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
    cond do
      role == "server" ->
        state = :running
        TwitterHelper.startNode
        {:ok, pid} = GenServer.start(Server, state, name: :server)
        GenServer.call(:server, :start, :infinity)
        #IO.inspect Process.alive?(pid)
      role == "client" ->
        Client.start
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
    |> OptionParser.parse(strict: [:integer, :string, :string])
    word
  end
end
