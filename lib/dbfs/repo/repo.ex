defmodule DBFS.Repo do
  use Ecto.Repo, otp_app: :dbfs
  use Scrivener, page_size: 10

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


    def keys(enum) do
      Keyword.keys(enum.__enum_map__())
    end
  end


  # Pager Helpers
  defmodule Pager do

    # Fetch pager entries
    def entries(%Scrivener.Page{entries: entries}), do: entries
    def entries(term), do: term


    # Page a query
    defdelegate paginate(query, opts \\ nil), to: DBFS.Repo
  end

end
