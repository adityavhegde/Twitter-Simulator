defmodule Client do
  use GenServer
  def start do
    #userName = :md5
    #            |> :crypto.hash(to_string(self()))
    #            |> Base.encode16()
    #            |> String.to_atom
    GenServer.call(:server, {:register, self()}, :infinity)
  end
end