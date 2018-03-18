defmodule DBFS.Consensus do
  alias DBFS.Consensus

  defdelegate status, to: Consensus.Cluster

  def sync do
    sync(Consensus.Node.name)
  end

  def sync(node) do
    Node.spawn(node, fn -> Consensus.Cluster.sync end)
  end

  def sync_all do
    Consensus.Election.ensure_leader!

    Enum.each(Consensus.Node.list, &sync/1)
  end

end
