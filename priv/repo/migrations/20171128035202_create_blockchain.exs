defmodule DBFS.Repo.Migrations.CreateBlockchain do
  use Ecto.Migration

  def change do
    create table(:blockchain) do
      add :data, :map
    end

    create table(:blocks) do
      add :timestamp, :naive_datetime, null: false
      add :type,      :integer,        null: false
      add :prev,      :string,         null: false
      add :hash,      :string,         null: false
      add :signature, :text,           null: false
      add :creator,   :text,           null: false
      add :data,      :map,            null: false, default: "{}"
    end

    create index(:blocks, [:hash])
    create index(:blocks, [:prev])
    create index(:blocks, [:creator])
  end
end
