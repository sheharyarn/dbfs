defmodule DBFS.Repo do
  use Ecto.Repo, otp_app: :dbfs

  @doc """
  Dynamically loads the repository url from the
  DATABASE_URL environment variable.
  """
  def init(_, opts) do
    {:ok, Keyword.put(opts, :url, System.get_env("DATABASE_URL"))}
  end


  # Define Application Enums
  defmodule Enums do
    import EctoEnum

    defenum Block.Type,
      zero:        0,
      file_create: 1,
      file_delete: 2
  end


  # Define Custom Schema Macro
  defmodule Schema do
    defmacro __using__(_opts) do
      quote do
        use Ecto.Schema
        use Ecto.Rut, repo: DBFS.Repo

        import  Ecto.Changeset
        require Ecto.Query

        alias DBFS.Repo
        alias DBFS.Repo.Enums
      end
    end
  end

end
