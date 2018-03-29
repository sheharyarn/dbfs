defmodule DBFS.Web.Controllers.API.V1.Block do
  use DBFS.Web, :controller


  @doc "GET: All Blocks"
  def index(conn, params) do
    render(conn, :index, pager: DBFS.Block.paged(page: params[:page]))
  end


  @doc "GET: Block Status"
  def show(conn, %{hash: hash}) do
    with {:ok, block} <- get(hash) do
      render(conn, :show, block: block)
    end
  end


  @doc "GET: Block Data"
  def file(conn, %{hash: hash}) do
    with {:ok, block} <- get(hash) do
      render(conn, :file, file: DBFS.Block.File.load!(block))
    end
  end


  @doc "POST: Create a new block"
  def create(conn, %{data: data, block: block}) do
    transaction = DBFS.Blockchain.insert_sync(block, data)

    with {:ok, %{block: block}} <- transaction do
      render(conn, :show, block: block)
    end
  end




  defp get(hash) do
    case DBFS.Block.get(hash) do
      nil   -> {:error, :not_found}
      block -> {:ok, block}
    end
  end

end
