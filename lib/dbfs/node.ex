defmodule DBFS.Node do
  @master Application.get_env(:dbfs, :master_node)


  def list do
    [ node() | Node.list ]
  end


  def join(cnode \\ @master) do
    if (node() != cnode) do
      Node.ping(cnode)
    end
  end

  def broadcast do
  end

  def cluster_status do
    statuses =
      list()
      |> Enum.map(&:rpc.call(&1, DBFS.Node, :local_status, []))
      |> Enum.zip(list())
      |> Enum.map(fn {status, name} -> Map.put(status, :name, name) end)

    max =
      statuses
      |> Enum.map(&(&1.count))
      |> Enum.max

    Enum.map(statuses, &sync_status(&1, max))
  end


  def local_status do
    DBFS.Blockchain.status(:core)
  end

  defp sync_status(status, max) do
    %{
      last_hash: status.last_hash,
      name: status.name,
      sync: round(status.count * 100 / max),
    }
  end

end
