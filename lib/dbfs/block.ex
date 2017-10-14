defmodule DBFS.Block do
  alias DBFS.Block
  alias DBFS.Blockchain

  @moduledoc "Basic building block of our Blockchain"

  @allowed_types [:file_create, :file_delete]
  @zero_type :zero
  @all_types [@zero_type | @allowed_types]

  defstruct [:type, :prev, :data, :signature, :hash, :creator, :timestamp]



  @doc "Block Zero a.k.a starting point of the blockchain"
  def zero do
    %Block{
      type: @zero_type,
      prev: Application.get_env(:dbfs, :zero_hash),
      timestamp: NaiveDateTime.utc_now()
    }
  end



  @doc "Create a new Block from a Blockchain or an existing one"
  def new(%Blockchain{} = chain) do
    Blockchain.head(chain) |> new
  end

  def new(%Block{hash: hash}) do
  end



  @doc "Validate a block using previous block's hash"
  def validate(%Block{} = block, %Block{hash: prev_hash}) do
    validate(block, prev_hash)
  end

  def validate(%Block{hash: hash, prev: reference} = block, prev_hash) do
    cond do
      (reference != prev_hash) ->
        {:error, :unmatched_reference}

      (hash(block) != hash) ->
        {:error, :invalid_hash}

      true ->
        :ok
    end
  end



  @doc "Calculate a block's hash"
  def hash(%Block{} = block) do
    # TODO: Implement
  end


  @doc "Calculate and set hash of the block"
  def set_hash!(%Block{} = block) do
    %{ block | hash: hash(block) }
  end



  @doc "Calculate signature of block data"
  def signature(%Block{} = block) do
  end

end
