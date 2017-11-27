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
        Simulator.searchTweets(actorsPid, :interval)
        #Simulator.searchMentions(actorsPid)
        #Simulator.searchHashtags(actorsPid)
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
