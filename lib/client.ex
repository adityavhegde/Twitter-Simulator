defmodule Client do
  use GenServer
  def start do
    #userName = :md5
    #            |> :crypto.hash(to_string(self()))
    #            |> Base.encode16()
    #            |> String.to_atom
    Node.start :"client@127.0.0.1"#<>TwitterHelper.getIp
    Node.set_cookie :twitter
    IO.inspect Node.self
    Node.connect :"server@127.0.0.1"#<>TwitterHelper.getIp
    GenServer.call({:server, :"server@127.0.0.1"} ,:register, :infinity)
  end
end