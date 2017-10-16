defmodule DBFS.Block do
  alias DBFS.Crypto
  alias DBFS.Block
  alias DBFS.Blockchain

  defstruct [:type, :prev, :data, :signature, :hash, :creator, :timestamp]


  @zero %{
    type:   :zero,
    pvtkey: Application.get_env(:dbfs, :zero_key),
    pubkey: Crypto.public_key(Application.get_env(:dbfs, :zero_key)),
    hash:   Crypto.sha256(Application.get_env(:dbfs, :zero_cookie)),
  }

  @allowed_types [:file_create, :file_delete]
  @all_types [@zero.type | @allowed_types]




  @doc "Block Zero a.k.a starting point of the blockchain"
  def zero do
    block =
      %Block{
        data: %{},
        type: @zero.type,
        prev: @zero.hash,
        creator: @zero.pubkey,
        timestamp: NaiveDateTime.utc_now()
      }

    block
    |> Crypto.sign!(@zero.pvtkey)
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
