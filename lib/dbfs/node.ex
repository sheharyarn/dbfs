defmodule DBFS.Node do


  def list do
    nodes = [ node() | Node.list ]

    Enum.map(nodes, &%{ name: &1, sync: 100 })
  end

end
