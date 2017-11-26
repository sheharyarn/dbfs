defmodule DBFS.Web.Controllers.API.V1.Main do
  use DBFS.Web, :controller


  @doc "GET: Application Status"
  def index(conn, _params) do
    render(conn, :index, blockchain: DBFS.Blockchain.load)
  end

end
