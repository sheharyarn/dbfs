defmodule DBFS.Web.Controllers.API.V1.Main do
  use DBFS.Web, :controller


  @doc "GET: Application Status"
  def index(conn, _params) do
    status = DBFS.Blockchain.status
    nodes  = DBFS.Consensus.Cluster.status

    conn
    |> determine_code(status)
    |> render(:index, status: status, nodes: nodes)
  end



  @doc "GET: Node Status"
  def nodes(conn, _params) do
    nodes = DBFS.Consensus.status
    count = DBFS.Blockchain.status.count

    render(conn, :nodes, nodes: nodes, block_count: count)
  end



  defp determine_code(conn, %{status: :error}), do: put_status(conn, 404)
  defp determine_code(conn, _), do: conn
end
