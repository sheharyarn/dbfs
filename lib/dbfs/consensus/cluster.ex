defmodule DBFS.Consensus.Cluster do
  alias DBFS.Block
  alias DBFS.Blockchain
  alias DBFS.Consensus

  require Logger

  @doc "Synchronize with the network"
  def sync do
    leader = Consensus.Election.ensure_leader!

    if !Consensus.Node.self?(leader) do
      leader = Consensus.Node.status(leader)
      update_until_synced(leader)
    end
  end

  defp update_until_synced(leader) do
    current = Consensus.Node.status

    cond do
      current.count < leader.count ->
        Logger.debug("#{node()} - Count Less than Leader")
        sync_next(leader.name, current.last_hash)
        update_until_synced(leader)

      true ->
        Logger.debug("#{node()} - Stopping sync")
        :ok
    end
  end


  defp sync_next(node, hash) do
    %{block: block, file: file} = :rpc.call(node, Block.File, :next, [hash])
    Blockchain.insert(Map.from_struct(block), file)
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
