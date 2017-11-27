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

  def sendTweet(clientUserName, tweetText) do
    # gets a send tweet request
    # send tweetMessage to server
    GenServer.cast({:server, :"server@127.0.0.1"}, {:tweet_subscribers, tweetText, clientUserName})
  end

  def retweet do
    # receive a tweet
    # send a tweet like the sendTweet function
  end

  def queryTweets do
    # request the server when this client goes from sleep to live
  end

  def subscribeUsers(usernamesToSub) do
    GenServer.call({:server, :"server@127.0.0.1"}, {:subscribe, usernamesToSub, self()}, :infinity)
  end

  def register(userName) do
    GenServer.call({:server, :"server@127.0.0.1"}, {:register, userName}, :infinity)
  end

#-------------------------------------------------------------------------------
#GenServer callbacks for the client

  def handle_call({:register, userName}, _, state) do
    #IO.inspect self()
    Client.register(userName)
    {:reply, {:registered}, state}
  end

  #tell a client PID to subscribe to a list of users' PIDs
  def handle_cast({:subscribe, usernamesToSub}, state) do
    Client.subscribeUsers(usernamesToSub)
    {:reply, {:subscribed}, state}
  end

  def handle_cast({:tweet_subscribers, tweetText, userName}) do
    GenServer.cast({:server, :"server@127.0.0.1"}, {:tweet_subscribers, tweetText, userName})
  end

  #GenServer callback to search for tweets of all users "userName" has subscribed to
  def handle_cast({:search, userName}) do
    GenServer.cast({:server, :"server@127.0.0.1"}, {:search})
  end

  #GenServer.callback to receive tweets from users subscribed to
  def handle_cast({:search_result, tweetText}) do
    IO.puts tweetText
  end


  def init(state) do
    {:ok, state}
  end
end
