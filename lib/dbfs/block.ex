defmodule DBFS.Block do
  use DBFS.Repo.Schema

  alias DBFS.Crypto
  alias DBFS.Block
  alias DBFS.Blockchain


  @zero %{
    type:   :zero,
    pvtkey: Application.get_env(:dbfs, :zero_key),
    pubkey: Crypto.public_key(Application.get_env(:dbfs, :zero_key)),
    hash:   Crypto.sha256(Application.get_env(:dbfs, :zero_cookie)),
  }

  @allowed_types [:file_create, :file_delete]
  @allowed_fields [:type, :data, :creator]
  @all_types [@zero.type | @allowed_types]

  @fields_required [:type, :data, :prev, :hash, :creator, :signature, :timestamp]


  schema "blocks" do
    field :type,      Enums.Block.Type
    field :data,      :map
    field :prev,      :string
    field :hash,      :string
    field :creator,   :string
    field :signature, :string
    filed :timestamp, :naive_datetime
  end


  def changeset(schema, params) do
    schema
    |> cast(params, @fields_required)
    |> validate_required(@fields_required)
    |> validate_hash
  end


  @doc "Get last block"
  def last do
    __MODULE__
    |> Ecto.Query.last
    |> Repo.one
  end


  defp validate_hash(changeset) do
    prev  = last()
    block = apply_changes(changeset)

    case validate(block, prev) do
      :ok ->
        changeset

      {:error, error} ->
        add_error(changeset, :crypto, error)
    end
  end


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
  def new(%Blockchain{} = chain, opts) do
    Blockchain.head(chain) |> new(opts)
  end

  def new(%Block{hash: hash}, opts) do
    block =
      %Block{
        prev: hash,
        timestamp: NaiveDateTime.utc_now(),
      }

    cast(block, opts)
  end



  @doc "Validate a block using previous block's hash"
  def validate(%Block{prev: prev} = block) do
    validate(block, prev)
  end

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
