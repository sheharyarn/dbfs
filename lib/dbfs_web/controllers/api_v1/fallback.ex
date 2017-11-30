defmodule DBFS.Web.Controllers.API.V1.Fallback do
  use DBFS.Web, :controller


  @basic_errors [:not_found, :unprocessable_entity, :forbidden]

  def call(conn, {:error, error}) when error in @basic_errors do
    conn
    |> put_status(error)
    |> error(error)
  end



  def call(conn, _) do
    conn
    |> put_status(:unprocessable_entity)
    |> error(:unknown_error)
  end


  defp error(conn, error) do
    render(conn, Views.Fallback, :error, error: error)
  end
end
