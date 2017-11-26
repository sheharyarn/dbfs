defmodule DBFS.Web.Controllers.API.V1.Main do
  use DBFS.Web, :controller


  @doc "GET: Application Status"
  def index(conn, _params) do
    blockchain = DBFS.Blockchain.load

    conn
    |> determine_status(blockchain)
    |> render(:index, blockchain: blockchain)
  end



  defp determine_status(conn, nil), do: put_status(conn, 404)
  defp determine_status(conn, ___), do: conn
end
