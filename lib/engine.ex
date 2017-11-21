defmodule Engine do
    use GenServer
    #function to initialize in-memory tables
    def initTables do
        #initialize users table with user_id and username
        userTable = :ets.new(:users, [:set, :private])
    end

    def register(userName) do
        
    end
end