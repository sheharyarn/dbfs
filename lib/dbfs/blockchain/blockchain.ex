defmodule DBFS.Blockchain do
  import DBFS.Repo.Multi

  alias DBFS.Repo
  alias DBFS.Block
  alias DBFS.Blockchain

  @moduledoc """
  A naive Blockchain data structure implemented on top
  of a Linked List
  """



  defstruct [:chain, :count]


  # @doc "Create a new blockchain with a zero block"
  # def new do
  #   %Blockchain{chain: [Block.zero()], count: 1}
  # end


  # @doc "Get the newest block on the chain"
  # def head(%Blockchain{chain: [head | _tail]}) do
  #   head
  # end


  # @doc "Add a new block to the chain"
  # def add(%Blockchain{} = bc, %Block{} = block) do
  #   %{ bc | chain: [block | bc.chain], count: bc.count + 1 }
  # end


  defdelegate insert(block), to: Blockchain.Schema

  def status do
    case load() do
      nil ->
        %{status: :error, message: :doesnt_exist}

      %Blockchain{count: count} ->
        %{
          status: :active,
          count:  count,
          recent: Block.paged(nil),
        }
    end
  end

  def load do
    case Blockchain.Schema.get do
      nil ->
        nil

      chain ->
        %Blockchain{ count: chain.count, chain: Block.all }
    end
  end

  def initialize do
    cond do
      Blockchain.Schema.get ->
        {:error, "Blockchain already exists"}

      Block.last ->
        {:error, "An orphan block exists in the database"}

      true ->
        zero =
          Block.zero
          |> Block.changeset
          |> Ecto.Changeset.apply_changes
          |> Repo.insert!

        Blockchain.Schema.insert!(count: 1, last_hash: zero.hash)
        {:ok, load()}
    end
  end


  def valid? do
    Block.all
    |> Enum.reverse
    |> Enum.map(&Block.Validations.validate/1)
    |> Enum.all?(&(:ok == &1))
  end


  @doc "Normalize responses"
  def normalize({:ok, term}),     do: {:ok, term}
  def normalize({:error, error}), do: {:error, {:blockchain, error}}
  def normalize(term),            do: {:error, {:blockchain, term}}



  # Inspect Protocol Implementation
  defimpl Inspect, for: __MODULE__ do
    def inspect(%{count: c, chain: [%{hash: h} | _]}, opts), do: str(c, h)
    def inspect(%{count: 0, chain: []}, opts),               do: str(0, nil)
    def inspect(_, opts),                                    do: "#Blockchain<invalid>"

    defp str(count, last) do
      "#Blockchain<blocks: #{count}, last: #{last}>"
    end
  end

end



