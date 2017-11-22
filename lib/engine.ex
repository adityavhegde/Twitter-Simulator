defmodule Engine do
    use GenServer
    def startServer do
        os = :os.type |> elem(0) |> Atom.to_string
        #get the ip of current node, and start it
        {:ok, list_ips} = :inet.getif()
        current_ip = if os  =~ "win" do
            list_ips 
            |> Enum.at(1) 
            |> elem(0) 
            |> Tuple.to_list
            |> Enum.join(".")
        else
            list_ips 
            |> Enum.at(0) 
            |> elem(0) 
            |> :inet_parse.ntoa 
            |> IO.iodata_to_binary
        end
        nodeFullName = "server@"<>current_ip
        Node.start String.to_atom(nodeFullName)
        Node.set_cookie :xyzzy
        IO.inspect {Node.self, Node.get_cookie}

        #IO.inspect self()
        #IO.inspect Node.start(:server)
        #IO.inspect Process.alive?(self())#Node.alive?()#get_cookie()
        #Node.start :server@server
        #Node.set_cookie (self(), :twitter)
    end

    #function to initialize in-memory tables
    def initTables do
        #initialize users table with user_id and username
        :ets.new(:users, [:set, :protected, :named_table])
    end

    #userName is client's PID
    def register(userName) do
        :ets.insert_new(:users, {userName, []})
    end

    #subscribe to a user
    def subscribe(userToFollow) do
        
    end
end