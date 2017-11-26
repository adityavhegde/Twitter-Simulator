defmodule Engine do
    use GenServer
    def startServer do
        nodeFullName = "server@127.0.0.1"
        Node.start (String.to_atom(nodeFullName))
        Node.set_cookie :twitter
        #IO.inspect {Node.self, Node.get_cookie}
    end

    def initTables do
        #initialize all tables. See moduledoc for details
        :ets.new(:users, [:set, :public, :named_table])
        :ets.new(:following, [:set, :public, :named_table])
        :ets.new(:tweets, [:set, :public, :named_table])
        :ets.new(:hashtag, [:set, :public, :named_table])
        :ets.new(:userPid, [:set, :public, :named_table])
        :ets.new(:userMentions, [:set, :public, :named_table])
    end

    #userName is client's PID
    def register(clientPid, userName) do
        :ets.insert_new(:users, {clientPid, userName, []})
        :ets.insert_new(:userPid, {userName, clientPid})
        #IO.inspect :ets.lookup(:users, clientPid)
    end

    #def subscribe(userToSubPid, clientPid) do
    #    IO.inspect :ets.lookup(:users, userToSubPid)
    #end
    #subscribe to a user
    def subscribe(userToSubPid, clientPid) do
        #IO.inspect [clientPid, "subscribing to", userToSubPid]
        #IO.inspect :ets.lookup(:users, userToSubPid)
        [{userToSubPid, userName, followers}] = :ets.lookup(:users, userToSubPid)
        followers = followers ++ [clientPid]
        :ets.insert(:users, {userToSubPid, userName, followers})
        IO.inspect :ets.lookup(:users, clientPid)

        # also insert in the following table
        listOfPeopleIFollow = cond do 
            :ets.member(:following, clientPid) ->
                [{_, listOfPeopleIFollow}] = :ets.lookup(:following, clientPid)
                listOfPeopleIFollow ++ [userToSubPid]
            true ->
                [userToSubPid]
        end
        :ets.insert(:following, {clientPid, listOfPeopleIFollow})
        #IO.inspect ["following", :ets.lookup(:following, clientPid)]
    end
    
  #----------------------------------------------------------------------------
  # Below: functions that only read from database
  # Do not add write functions
    @spec getFollowers(pid) :: list
    def getFollowers(userPid) do
        #IO.inspect :ets.lookup(:users, userPid)
        :ets.lookup(:users, userPid) |> Enum.at(0) |> elem(2)
    end
end