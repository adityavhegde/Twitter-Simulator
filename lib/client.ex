defmodule Client do
  use GenServer
#to start an actor
  def start(clientSerial) do
    IO.inspect self()
    userName = :md5
                |> :crypto.hash(clientSerial)
                |> Base.encode16()
                #|> String.to_atom
    #IO.inspect userName
    nodeName = userName<>"@127.0.0.1"
    #nodeName = "client@127.0.0.1"
    #IO.puts nodeName
    Node.start String.to_atom(nodeName)#:"client@127.0.0.1"
    Node.set_cookie :twitter
    IO.inspect Node.self
    #Node.connect :"server@127.0.0.1"
    GenServer.call({:server, :"server@127.0.0.1"} , {:register, userName}, :infinity)
  end

  #to start multiple actors
  def start() do
    userName = :md5
                |> :crypto.hash(Kernel.inspect(self))
                |> Base.encode16()
  end

  def sendTweet(tweetText) do
    # gets a send tweet request
    # send tweetMessage to server
    GenServer.cast({:server, :"server@127.0.0.1"}, {:tweet_subscribers, tweetText, self})
  end

  def retweet do
    # receive a tweet
    # send a tweet like the sendTweet function
  end

  def queryTweets do
    # request the server when this client goes from sleep to live
  end

  def subscribeUsers(usersToSub) do
    GenServer.cast({:server, :"server@127.0.0.1"}, {:subscribe, usersToSub, self()})
  end

  def register(userName) do
    GenServer.call({:server, :"server@127.0.0.1"}, {:register, userName}, :infinity)
  end

#---------------------------------------------------------------------
#GenServer callbacks for the client

  def handle_call({:register, userName}, _, state) do
    #IO.inspect self()
    Client.register(userName)
    {:reply, {:registered}, state}
  end

  #tell a client PID to subscribe to a list of users' PIDs
  def handle_call({:subscribe, usersToSub}, userPid, state) do
    Client.subscribeUsers(usersToSub)
    {:reply, {:subscribed}, state}
  end

  def init(state) do
    {:ok, state}
  end
end