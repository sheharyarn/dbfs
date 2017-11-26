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

  @fields_required [:id, :type, :data, :prev, :hash, :creator, :signature, :timestamp]
  @derive {Poison.Encoder, only: @fields_required}


  schema "blocks" do
    field :type,      Enums.Block.Type
    field :data,      :map
    field :prev,      :string
    field :hash,      :string
    field :creator,   :string
    field :signature, :string
    field :timestamp, :naive_datetime
  end


  def changeset(schema, params \\ %{}) do
    schema
    |> cast(params, @fields_required)
    |> validate_required(@fields_required)
    |> validate
  end


  @doc "Get last block"
  def last do
    Block
    |> Query.last
    |> Repo.one
  end

  def paged(opts) do
    Block
    |> Query.order_by(desc: :id)
    |> Pager.paginate(opts)
  end

  defoverridable [all: 0]
  def all do
    Block
    |> Query.order_by(desc: :id)
    |> Repo.all
  end


  defoverridable [get: 1]
  def get(hash) do
    Block
    |> Query.where([b], b.hash == ^hash)
    |> Repo.one
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
  def new(%Block{hash: hash}, params \\ %{}) do
    params =
      params
      |> Enum.into(%{})
      |> Map.put(:prev, hash)
      |> Map.put(:timestamp, NaiveDateTime.utc_now())

    changeset(%Block{}, params)
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

  def validate(%Ecto.Changeset{} = changeset) do
    prev  = last()
    block = apply_changes(changeset)

    case validate(block, prev) do
      :ok ->
        changeset

      {:error, error} ->
        add_error(changeset, :crypto, to_string(error))
    end
  end

end
