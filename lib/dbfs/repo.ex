defmodule DBFS.Repo do
  use Ecto.Repo, otp_app: :dbfs

  @doc """
  Dynamically loads the repository url from the
  DATABASE_URL environment variable.
  """
  def init(_, opts) do
    {:ok, Keyword.put(opts, :url, System.get_env("DATABASE_URL"))}
  end


  defmodule Schema do
    defmacro __using__(_opts) do
      quote do
        use Ecto.Schema
        use Ecto.Rut, repo: DBFS.Repo

        import  Ecto.Changeset
        require Ecto.Query

        alias DBFS.Repo
      end
    end
  end

end
