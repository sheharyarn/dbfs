defmodule DBFS.Repo.Schema do

  # Define Custom Schema Macro
  defmacro __using__(_opts) do
    quote do
      use Ecto.Schema
      use Ecto.Rut, repo: DBFS.Repo

      import  Ecto.Changeset
      require Ecto.Query

      alias Ecto.Query
      alias DBFS.Repo
      alias DBFS.Repo.Enums
      alias DBFS.Repo.Pager
    end
  end

end

