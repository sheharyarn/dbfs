defmodule DBFS.Web.Controllers.API.V1.Block do
  use DBFS.Web, :controller


  @doc "GET: All Blocks"
  def index(conn, params) do
    render(conn, :index, pager: DBFS.Block.paged(page: params[:page]))
  end


  @doc "GET: Block Status"
  def show(conn, %{hash: hash}) do
    with {:ok, block} <- get(hash) do
      render_block(conn, block)
    end
  end


  @doc "GET: Block Data"
  def file(conn, %{hash: hash}) do
    with {:ok, block} <- get(hash) do
      render(conn, :file, file: DBFS.Block.File.load!(block))
    end
  end



  @doc "POST: Create a new block (with or without file)"
  def create(conn, %{block: block, data: data}) do
    transaction = case data do
      nil ->
        DBFS.Blockchain.insert_sync(block)

      _ ->
        DBFS.Blockchain.insert_sync(block, data)
    end

    with {:ok, %{block: block}} <- transaction do
      render_block(conn, block)
    end
  end




  defp get(hash) do
    case DBFS.Block.get(hash) do
      nil   -> {:error, :not_found}
      block -> {:ok, block}
    end
  end


  defp render_block(conn, block) do
    # TODO:
    # Also return the hash of the next block

    meta = %{
      deleted: DBFS.Block.is_deleted?(block),
      last:    DBFS.Block.last.hash,
      prev:    block.prev,
      next:    nil,
    }

    render(conn, :show, block: block, meta: meta)
  end

end
