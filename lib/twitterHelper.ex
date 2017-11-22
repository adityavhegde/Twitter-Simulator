defmodule TwitterHelper do
    def startNode do
        #get the ip of current node, and start it
        {:ok, list_ips} = :inet.getif()
        current_ip = list_ips 
            |> Enum.at(0) 
            |> elem(0) 
            |> :inet_parse.ntoa 
            |> IO.iodata_to_binary
            
        IO.inspect current_ip
        nodeFullName = "server@"<>current_ip
        Node.start (String.to_atom(nodeFullName))
        Node.set_cookie :xyzzy
        IO.inspect {Node.self, Node.get_cookie}
    end
end