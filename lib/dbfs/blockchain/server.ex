defmodule DBFS.Blockchain.Server do
  use GenServer
  alias DBFS.Blockchain

  @module __MODULE__


  @doc "Start GenServer"
  def start_link do
    GenServer.start_link(@module, :ok, name: @module)
  end


  @doc "Initialize Blockchain"
  def init(:ok) do
    {:ok, Blockchain.load()}
  end



  @doc "Get the complete blockchain"
  def handle_call({:add, block_params}, _from, chain) do
    with :ok <- validate(chain) do
      case Blockchain.add(chain, block_params) do
        {:ok, chain} ->
          wrap(:ok, chain)

        other ->
          Blockchain.normalize(other) |> wrap(chain)
      end
    end
  end





  # Validate that the chain can be worked on
  defp validate(chain) do
    case chain do
      %Blockchain{} ->
        :ok

      nil ->
        Blockchain.normalize(:uninitialized) |> wrap(chain)

      _ ->
        Blockchain.normalize(:invalid) |> wrap(chain)
    end
  end


  # Wrap the response in a reply tuple
  defp wrap(term, chain) do
    {:reply, term, chain}
  end

end
