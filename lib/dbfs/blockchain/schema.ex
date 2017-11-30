defmodule DBFS.Blockchain.Schema do
  use DBFS.Repo.Schema
  alias DBFS.Block
  import DBFS.Repo.Multi


  @fields_required [:count]
  @fields_optional [:last_hash]
  @fields_all      (@fields_required ++ @fields_optional)


  schema "blockchain" do
    embeds_one :data, Data,
      primary_key: false,
      on_replace: :update
    do
      field :count,     :integer
      field :last_hash, :string
    end
  end


  def changeset(schema, params) do
    schema
    |> cast(%{data: params}, [])
    |> cast_embed(:data, with: &data_changeset/2)
  end

  defp data_changeset(schema, params) do
    schema
    |> cast(params, @fields_all)
    |> validate_required(@fields_required)
  end



  defoverridable [get: 1]
  def get(:main) do
    __MODULE__
    |> Query.last
    |> Repo.one
  end

  def get do
    case struct = get(:main) do
      %__MODULE__{} -> struct.data
      _             -> nil
    end
  end


  def delete do
    Repo.delete_all(__MODULE__)
  end

  def increment(hash) do
    chain = get(:main)
    update(chain, count: chain.data.count + 1, last_hash: hash)
  end





  defoverridable [insert: 1]
  def insert(%{} = block) do
    Ecto.Multi.new
    |> run_operation(:block, block)
    |> run_operation(:chain, nil)
    |> Repo.transaction
  end

  defp block(_changes, block) do
    %Block{}
    |> Block.changeset(block)
    |> Block.insert
  end

  defp chain(%{block: %{hash: hash}}, nil) do
    increment(hash)
  end

end
