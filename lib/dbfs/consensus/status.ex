defmodule DBFS.Consensus.Status do
  use GenServer

  alias DBFS.Consensus
  alias DBFS.Blockchain


  # TODO:
  # Modify to hold node's consensus status


  def get do
    case Blockchain.Schema.get do
      nil ->
        %{status: :error, message: :doesnt_exist}

      %{} = schema ->
        status = get(:node)

        schema
        |> Map.from_struct
        |> Map.merge(status)
    end
  end


  def get(:node) do
    GenServer.call(Consensus.Node.name, :get_state)
  end


  def set(:active),                     do: set!(%{status: :active})
  def set(:waiting),                    do: set!(%{status: :waiting})
  def set(:syncing,    with: node),     do: set!(%{status: :syncing,    with: node})
  def set(:correcting, with: node),     do: set!(%{status: :correcting, with: node})


  defp set!(%{} = state) do
    GenServer.call(Consensus.Node.name, {:set_state, state})
  end



  # ---



  def start_link do
    GenServer.start_link(__MODULE__, %{status: :initializing}, name: Consensus.Node.name)
  end

  def init(state) do
    {:ok, state}
  end


  def handle_call({:set_state, state}, _from, _old_state) when is_map(state) do
    {:reply, :ok, state}
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

end
