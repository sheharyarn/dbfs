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


  def insert(%{} = block) do
    Ecto.Multi.new
    |> run_operation(:insert_block, block)
    |> run_operation(:update_chain, nil)
    |> Repo.transaction
  end

  defp insert_block(_changes, block) do
    %Block{}
    |> Block.changeset(block)
    |> Block.insert
  end

  defp update_chain(%{insert_block: %{hash: hash}}, nil) do
    Blockchain.Schema.increment(hash)
  end



  def load(), do: nil

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


  @doc "Normalize responses"
  def normalize({:ok, term}),     do: {:ok, term}
  def normalize({:error, error}), do: {:error, {:blockchain, error}}
  def normalize(term),            do: {:error, {:blockchain, term}}
end
