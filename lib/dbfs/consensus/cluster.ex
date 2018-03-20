defmodule DBFS.Consensus.Cluster do
  alias DBFS.Block
  alias DBFS.Blockchain
  alias DBFS.Consensus

  require Logger

  @doc "Synchronize with the network"
  def sync do
  end



  @doc "Get entire cluster's status"
  def status do
    network_state().statuses
  end



  def network_state do
    list = Consensus.Node.list

    statuses =
      list
      |> Enum.map(&Consensus.Node.status/1)
      |> Enum.zip(list)
      |> Enum.map(fn {status, name} -> Map.put(status, :name, name) end)

    max =
      statuses
      |> Enum.map(&(&1.count))
      |> Enum.max

    statuses = Enum.map(statuses,  &with_sync(&1, max))
    current  = Enum.find(statuses, &(Consensus.Node.name == &1.name))

    %{
      max:      max,
      nodes:    list,
      statuses: statuses,
      current:  current,
    }
  end




  defp with_sync(status, max) do
    sync = round(status.count * 100 / max)

    Map.put(status, :sync, sync)
  end

end
