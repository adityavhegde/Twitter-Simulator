defmodule Client do
  use GenServer
  def start do
    IO.inspect self()
    userName = :md5
                |> :crypto.hash(Kernel.inspect(self()))
                |> Base.encode16()
                #|> String.to_atom
    #IO.inspect userName
    #nodeName = userName<>"@127.0.0.1"
    #nodeName = "client@127.0.0.1"
    #IO.puts nodeName
    #Node.start String.to_atom(nodeName)#:"client@127.0.0.1"
    #Node.set_cookie :twitter
    #IO.inspect Node.self
    #Node.connect :"server@127.0.0.1"
    GenServer.call({:server, :"server@127.0.0.1"} , {:register, userName}, :infinity)
  end

  def requestMentions do
    # request the users this client can mention in tweet
    # this request is sent to the server (decide how often this happens)
    # update mentions in state
  end

  def sendTweet do
    # gets a send tweet request
    # generates a random tweet
    # add random hashtags
    # select a random mention from state (this was set using requestMentions)
    # send tweetMessage to server
  end

  def retweet do
    # receive a tweet
    # send a tweet like the sendTweet function
  end

  def queryTweets do
    # request the server when this client goes from sleep to live
  end

  def subscribeUsers(listOfClients) do
    GenServer.cast({:server, :"server@127.0.0.1"}, {:subscribe, listOfClients, self()})
  end

  def handle_call(:register, _, state) do
    Client.start
    {:reply, :registered, state}
  end

  def init(state) do
    {:ok, state}
  end
end