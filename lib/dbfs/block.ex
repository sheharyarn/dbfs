defmodule DBFS.Block do
  alias DBFS.Crypto
  alias DBFS.Block
  alias DBFS.Blockchain

  @moduledoc "Basic building block of our Blockchain"

  @allowed_types [:file_create, :file_delete]
  @all_types [@zero_type | @allowed_types]

  @zero_type   :zero
  @zero_hash   Application.get_env(:dbfs, :zero_hash)
  @zero_pvtkey Application.get_env(:dbfs, :zero_pvtkey)
  @zero_pubkey Application.get_env(:dbfs, :zero_pubkey)


  defstruct [:type, :prev, :data, :signature, :hash, :creator, :timestamp]



  @doc "Block Zero a.k.a starting point of the blockchain"
  def zero do
    block =
      %Block{
        data: {},
        type: @zero_type,
        prev: @zero_hash,
        creator: @zero_pubkey,
        timestamp: NaiveDateTime.utc_now()
      }

    block
    |> Crypto.sign!(@zero_pvtkey)
    |> Crypto.hash!
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
        {:error, :invalid_reference}

      (Crypto.hash(block) != hash) ->
        {:error, :invalid_hash}

      (Crypto.verify(block) != :ok) ->
        {:error, :invalid_signature}

      true ->
        :ok
    end
  end



end
