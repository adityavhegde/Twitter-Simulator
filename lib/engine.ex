defmodule Engine do
    use GenServer
    def startServer do
        nodeFullName = "server@127.0.0.1"
        Node.start (String.to_atom(nodeFullName))
        Node.set_cookie :twitter
        IO.inspect {Node.self, Node.get_cookie}
    end

    #function to initialize in-memory tables
    def initTables do
        #initialize users table with user_id and username
        :ets.new(:users, [:set, :protected, :named_table])
    end

    #userName is client's PID
    def register(clientPid, userName) do
        :ets.insert_new(:users, {userName, clientPid, []})
    end

    #subscribe to a user
    def subscribe(userToFollow) do
        
    end
end