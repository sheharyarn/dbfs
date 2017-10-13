defmodule DBFS.Block do
  alias DBFS.Block
  alias DBFS.Blockchain

  @moduledoc "Basic building block of our Blockchain"

  @allowed_types [:create, :delete]
  @zero_type :zero
  @all_types [@zero_type | @allowed_types]

  defstruct [:type, :prev, :data, :hash, :creator, :timestamp]



  @doc "Block Zero a.k.a starting point of the blockchain"
  def zero do
    %Block{
      type: @zero_type,
      prev: Application.get_env(:dbfs, :zero_hash),
      timestamp: NaiveDateTime.utc_now()
    }
  end



  @doc "Create a new Block from a Blockchain or an existing one"
  def new(%Blockchain{chain: chain}) do
    chain
    |> hd
    |> new
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
  end


  @doc "Calculate and set hash of the block"
  def hash!(%Block{} = block) do
    %{ block | hash: hash(block) }
  end

end
