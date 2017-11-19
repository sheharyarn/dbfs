defmodule DBFS.Blockchain.Schema do
  use DBFS.Repo.Schema


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



  def get do
    struct =
      __MODULE__
      |> Ecto.Query.last
      |> Repo.one

    case struct do
      %__MODULE__{} -> struct.data
      _             -> nil
    end
  end


  def delete do
    Repo.delete_all(__MODULE__)
  end

end
