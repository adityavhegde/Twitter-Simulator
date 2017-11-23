defmodule Engine do
    use GenServer
<<<<<<< HEAD
    def startServer do
        nodeFullName = "server@127.0.0.1"
        Node.start (String.to_atom(nodeFullName))
        Node.set_cookie :twitter
        #IO.inspect {Node.self, Node.get_cookie}
    end

    #function to initialize in-memory tables
=======
    function to initialize in-memory tables
>>>>>>> server
    def initTables do
        #initialize users table with user_id and username
        :ets.new(:users, [:set, :protected, :named_table])
    end

    #userName is client's PID
    def register(clientPid, userName) do
        #IO.inspect userName
        :ets.insert_new(:users, {clientPid, userName, []})
    end

<<<<<<< HEAD
    #subscribe to a user
    def subscribe(userToSub, clientPid) do
        IO.puts "here"
        IO.inspect :ets.lookup(:users, userToSub)
        [{userToSub, userPid, followers}] = :ets.lookup(:users, userToSub)
        followers = followers ++ clientPid
        :ets.insert(:users, {userToSub, userPid, followers})
        IO.inspect :ets.lookup(:users, userToSub)
    end

    #get keys of ets table
    def keys(table_name) do
        first_key = :ets.first(table_name)
        keys(table_name, first_key, [first_key])
    end
    def keys(_table_name, '$end_of_table', ['$end_of_table'|acc]) do
        acc
    end
    def keys(table_name, current_key, acc) do
        next_key = :ets.next(table_name, current_key)
        keys(table_name, next_key, [next_key|acc])
=======
    def register(userName) do

    end
    def getFollowers(userName) do
      :ets.lookup(:users, username)
>>>>>>> server
    end
end
