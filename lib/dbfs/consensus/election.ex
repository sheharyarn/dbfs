defmodule DBFS.Consensus.Election do
  alias DBFS.Consensus

  def start do
    %{state: state} = get()

    cond do
      state == :electing ->
        {:error, :already_electing}

      true ->
        choose_leader!()
        :ok
    end
  end


  def ensure_leader! do
    current = get()

    if (current.state == :elected) and Consensus.Node.connected?(current.leader) do
      if (Consensus.Node.status.count > Consensus.Node.status(current.leader).count) do
        start()
      end

      get!()
    else
      start()
      get!()
    end
  end


  def get do
    Consensus.Global.get
  end


  def get! do
    %{state: state, leader: leader} = get()

    case state do
      :elected ->
        leader

      :electing ->
        Process.sleep(100)
        get!()
    end
  end


  defp set!(state, leader \\ nil) do
    Consensus.Global.set(%{state: state, leader: leader})
  end


  defp choose_leader! do
    set!(:electing)
    network = Consensus.Cluster.network_state

    # TODO:
    # Choosing the one with highest count for now.
    # In future also match hashes to revert back
    # state and perform corrections.

    leader =
      network
      |> Map.get(:statuses)
      |> Enum.find(&(network.max == &1.count))
      |> Map.get(:name)

    set!(:elected, leader)
  end

end
