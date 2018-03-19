defmodule DBFS.Consensus.Node do
  use GenServer


  @doc "Name of the node"
  def name do
    node()
  end


  @doc "List all nodes in cluster"
  def list do
    [ name() | Node.list ]
  end


  @doc "Add a new node to the cluster"
  def join(cnode) do
    if (node() != cnode) do
      Node.ping(cnode)
    end
  end


  @doc "Get current node's status"
  def status do
    DBFS.Consensus.Status.get |> Map.put(:name, name())
  end

  def status(node) do
    :rpc.call(node, DBFS.Consensus.Node, :status, [])
  end


  @doc "Check if node is connected"
  def connected?(node) do
    Enum.member?(list(), node)
  end


  @doc "Check if the node is self"
  def self?(%{name: name}), do: self?(name)
  def self?(node),          do: name() == node

end
