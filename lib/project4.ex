defmodule Server do
  use GenServer 
  def handle_call(:start, from, state) do
    Engine.initTables
  end
  def handle_call(:register, userName, state) do
    Engine.register(userName)
  end
end

defmodule Client do
  def start do
    
  end
end

defmodule Project4 do
  def main(args) do
    role = args
            |> parse_args
            |> Enum.at(0)
    cond do
      role == "server" ->
        {:ok, _} = GenServer.start(Server, state, name: :server)
        GenServer.call(:server, :start, :infinity)
      role == "client" ->
        Client.start
    end
  end

  #parsing the input argument
  defp parse_args(args) do
    {_, word, _} = args 
    |> OptionParser.parse(strict: [:integer, :string, :string])
    word
  end
end
