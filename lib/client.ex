defmodule Client do
  use GenServer
  def start do
    userName = :md5
                |> :crypto.hash(Kernel.inspect(self()))
                |> Base.encode16()
                |> String.to_atom
    #IO.inspect userName
    Node.start :"client@127.0.0.1"
    Node.set_cookie :twitter
    #IO.inspect Node.self
    Node.connect :"server@127.0.0.1"
    GenServer.call({:server, :"server@127.0.0.1"} , {:register, userName}, :infinity)
  end
end