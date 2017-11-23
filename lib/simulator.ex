#module for the separate client node OS process
defmodule Simulator do
  use GenServer
  def handle_cast(numClients, state) do
    state = :running
    IO.puts "spawning clients"
    Enum.each(1..numClients, fn(x) ->
        {:ok, pid} = GenServer.start(Client, state)
        GenServer.call(pid, :register, :infinity)
    end)
    
    IO.inspect GenServer.call({:server, :"server@127.0.0.1"}, :getUsers, :infinity)
    
    {:noreply, state}
  end
end