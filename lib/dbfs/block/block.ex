defmodule DBFS.Block do
  use DBFS.Repo.Schema

  import DBFS.Block.Validations

  alias DBFS.Crypto
  alias DBFS.Block
  alias DBFS.Blockchain


  @zero %{
    type:   :zero,
    pvtkey: Application.get_env(:dbfs, :zero_key),
    pubkey: Crypto.public_key(Application.get_env(:dbfs, :zero_key)),
    hash:   Crypto.sha256(Application.get_env(:dbfs, :zero_cookie)),
  }

  @allowed_types Enums.keys(Enums.Block.Type)
  @fields_required [:type, :data, :prev, :hash, :creator, :signature, :timestamp]
  @derive {Poison.Encoder, only: [:id | @fields_required]}


  schema "blocks" do
    field :type,      Enums.Block.Type
    field :data,      :map, default: %{}
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
    |> validate_data
    |> validate_crypto
  end



  @doc "Get first block"
  def first do
    Block
    |> Query.first
    |> Repo.one
    |> normalize_data
  end


  @doc "Get last block"
  def last do
    Block
    |> Query.last
    |> Repo.one
    |> normalize_data
  end


  @doc "Get the next block"
  def next(hash) do
    if prev = get(hash) do
      Block
      |> Query.where([b], b.id > ^prev.id)
      |> Query.first
      |> Repo.one
      |> normalize_data
    end
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
    |> normalize_data
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


  def normalize_data(%{data: data} = block) do
    %{ block | data: ExUtils.Map.symbolize_keys(data, deep: true) }
  end

  def normalize_data(term), do: term


  @doc "Create a new Block from a Blockchain or an existing one"
  def new(%Block{hash: hash}, params \\ %{}) do
    params =
      params
      |> Enum.into(%{})
      |> Map.put(:prev, hash)
      |> Map.put(:timestamp, NaiveDateTime.utc_now())

    changeset(%Block{}, params)
  end



  @doc "Check if the block file was deleted in a future block"
  def is_deleted?(%Block{type: :file_create, hash: hash, creator: creator}) do
    hash_map = %{parent_hash: hash}

    Block
    |> Query.where([b], b.type == ^:file_delete)
    |> Query.where([b], b.creator == ^creator)
    |> Query.where([b], fragment("? @> ?", b.data, ^hash_map))
    |> Repo.aggregate(:count, :id)
    |> Kernel.>(0)
  end

  def is_deleted?(_block), do: false



  @doc "Returns the number of each block type"
  def block_counts do
    counts =
      Block
      |> Query.group_by([b], b.type)
      |> Query.select([b], {b.type, count(b.id)})
      |> Repo.all

    Enum.map(@allowed_types, fn type ->
      { type, counts[type] || 0 }
    end)
  end


  @doc "Returns the number of file blocks - delete blocks"
  def file_count do
    counts = block_counts()

    counts[:file_create] - counts[:file_delete]
  end

end
