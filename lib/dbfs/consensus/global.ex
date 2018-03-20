defmodule DBFS.Consensus.Global do
  use Amnesia
  alias DBFS.Consensus.Global


  defdatabase DB do
    deftable Status, [:id, :content], type: :ordered_set do
      def get do
        data = Amnesia.transaction(do: read(1))

        if is_map(data) && data.content do
          data.content
        else
          Global.default
        end
      end

      def set(data) do
        Amnesia.transaction(do: write(%__MODULE__{id: 1, content: data}))
      end

    end
  end


  defdelegate get,       to: Global.DB.Status
  defdelegate set(data), to: Global.DB.Status


  def setup do
    list  = Node.list
    nodes = [node() | list]

    last_leader =
      if old = List.first(list) do
        :rpc.call(old, Global, :get, [])
      else
        default()
      end

    :rpc.multicall(nodes, Amnesia, :stop, [])
    Amnesia.Schema.destroy(nodes)
    Amnesia.Schema.create(nodes)
    :rpc.multicall(nodes, Amnesia, :start, [])

    Global.DB.Status.create
    Global.DB.wait(15000)
    Global.set(last_leader)
  end


  def default do
    %{state: nil, leader: nil}
  end

end
