defmodule TwitterHelper do
    def startNode do
        nodeFullName = "server@127.0.0.1"
        Node.start (String.to_atom(nodeFullName))
        Node.set_cookie :twitter
        IO.inspect {Node.self, Node.get_cookie}
    end   
end