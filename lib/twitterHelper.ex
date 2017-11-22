defmodule TwitterHelper do
    def startNode do
        #get the ip of current node, and start it
        {:ok, list_ips} = :inet.getif()
        current_ip = TwitterHelper.getIp
            
        IO.inspect current_ip
        nodeFullName = "server@127.0.0.1"#<>current_ip
        Node.start (String.to_atom(nodeFullName))
        Node.set_cookie :twitter
        IO.inspect {Node.self, Node.get_cookie}
    end

    def getIp do
        {:ok, list_ips} = :inet.getif()
        current_ip = list_ips 
            |> Enum.at(0) 
            |> elem(0) 
            |> :inet_parse.ntoa 
            |> IO.iodata_to_binary        
    end
end