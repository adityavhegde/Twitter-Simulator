defmodule Client do
  use GenServer
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
    GenServer.call({:server, :"server@127.0.0.1"}, {:subscribe, usernamesToSub}, :infinity)
  end

  def register(userName) do
    GenServer.call({:server, :"server@127.0.0.1"}, {:register, userName}, :infinity)
  end

#---------------------------------------------------------------------
#GenServer callbacks for the client from the simulator

  def handle_call({:register, userName}, _, state) do
    #IO.inspect self()
    Client.register(userName)
    {:reply, {:registered}, state}
  end

  #tell a client PID to subscribe to a list of users' PIDs
  def handle_cast({:subscribe, usernamesToSub}, state) do
    IO.puts "subscribing"
    Client.subscribeUsers(usernamesToSub)
    {:noreply, state}
  end

  def handle_cast({:tweet_subscribers, tweetText, userName}, state) do
    IO.puts "client tweeting"
    GenServer.cast({:server, :"server@127.0.0.1"}, {:tweet_subscribers, tweetText, userName})
    {:noreply, state}
  end

  #GenServer callback to search for tweets of all users "userName" has subscribed to
  def handle_cast({:search, userName}, state) do
    IO.puts "client will ask server for tweets"
    GenServer.cast({:server, :"server@127.0.0.1"}, {:search, userName})
    {:noreply, state}
  end

#GenServer callback to query for tweets with given hashtags
  def handle_cast({:search_hashtag, userName, hashtag_list}, state) do
    IO.puts "client will ask for hashtags"
    GenServer.cast({:server, :"server@127.0.0.1"}, {:search_hashtag, userName, hashtag_list})
    {:noreply, state}
  end

  #GenServer callback to search for tweets where user is mentioned
  def handle_cast({:search_mentions, userName}, state) do
    IO.puts "receiving tweets where client has been mentioned"
    GenServer.cast({:server, :"server@127.0.0.1"}, {:search_mentions, userName})
    {:noreply, state}
  end
#---------------------------------------------------
#GenServer Callbacks from server below this

  #GenServer.callback to receive tweets when users you have subscribed to tweets something
  def handle_cast({:receiveTweet, tweetText}, state) do
    IO.puts "receiving tweets"
    IO.puts tweetText
    {:noreply, state}
  end

  #GenServer.callback to receive tweets queried for
  def handle_cast({:search_result, tweetText}, state) do
    IO.puts "receiving tweets from users subscribed to"
    IO.puts tweetText
    {:noreply, state}
  end

  #GenServer.callback to receive tweets with hashtags queried for
  def handle_cast({:search_result_ht, tweetText}, state) do
    IO.puts "receiving tweets with given hashtags"
    IO.puts tweetText
    {:noreply, state}
  end

  #GenServer.callback to receive tweets with hashtags queried for
  def handle_cast(  {:search_result_mention, tweetText}, state) do
    IO.puts "receiving tweets where client is mentioned"
    IO.puts tweetText
    {:noreply, state}
  end

  def init(state) do
    {:ok, state}
  end
end
