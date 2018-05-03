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
    Process.sleep 1000
    current = Consensus.Node.status

    cond do
      current.count == 0 ->
        Logger.debug("#{node()} - Count = 0")
        sync_zero(leader.name)
        update_until_synced(leader)

      current.count < leader.count ->
        Logger.debug("#{node()} - Count Less than Leader")
        sync_next(leader.name, current.last_hash)
        update_until_synced(leader)

      true ->
        Logger.debug("#{node()} - Stopping sync")
        :ok
    end
  end


  defp sync_zero(node) do
    zero =
      :rpc.call(node, Block, :first, [])
      |> Block.changeset
      |> Ecto.Changeset.apply_changes
      |> DBFS.Repo.insert!

    Blockchain.Schema.increment(zero.hash)
  end

  defp sync_next(node, hash) do
    try do
      rpc_sync_block(node, hash)
    rescue
      Ecto.ConstraintError ->
        sync_next(node,hash)
    end
  end


  defp rpc_sync_block(node, hash) do
    %{block: block, file: file} = :rpc.call(node, Block.File, :next, [hash])
    block = Map.from_struct(block)

    cond do
      is_nil(file) ->
        Blockchain.insert(block)

      is_binary(file) ->
        Blockchain.insert(block, file)

      true ->
        raise "Invalid File Data"
    end
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
