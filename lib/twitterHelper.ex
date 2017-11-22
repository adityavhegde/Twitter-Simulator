defmodule TwitterHelper do
    def startNode do
        nodeFullName = "server@127.0.0.1"
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