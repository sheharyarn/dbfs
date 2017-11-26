defmodule DBFS.Web.Controllers.API.V1.Main do
  use DBFS.Web, :controller


  @doc "GET: Application Status"
  def index(conn, _params) do
    status = DBFS.Blockchain.status

    conn
    |> determine_code(status)
    |> render(:index, status: status)
  end



  defp determine_code(conn, %{status: :error}), do: put_status(conn, 404)
  defp determine_code(conn, _), do: conn
end
