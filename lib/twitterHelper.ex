#TODO: add this to server api
defmodule TwitterHelper do
    def startNode do
        nodeFullName = "server@127.0.0.1"
        Node.start (String.to_atom(nodeFullName))
        Node.set_cookie :twitter
        IO.inspect {Node.self, Node.get_cookie}
    end

    def getHashtag do
        hashList = ["#marketing", "#marketingtips", "#b2cmarketing", 
        "#b2bmarketing", "#strategy", "#mktg", "#digitalmarketing", 
        "#marketingstrategy", "#mobilemarketing", "#socialmediamarketing",
        "#promotion", "#food", "#yummy", "#nom", "#hungry", "#cleaneating", 
        "#vegetarian", "#wine", "#sushi", "#birthday", "#red", "#workout", 
        "#sweet",  "#wedding", "#blackandwhite"]
        Enum.random(hashList)
    end
end