defmodule DBFS.Web.Controllers.API.V1.Fallback do
  use DBFS.Web, :controller
  require Logger


  @basic_errors [:not_found, :unprocessable_entity, :forbidden]

  def call(conn, {:error, error}) when error in @basic_errors do
    conn
    |> put_status(error)
    |> render_error(error)
  end


  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    errors = normalize_changeset_errors(changeset)
    call(conn, {:error, errors})
  end


  def call(conn, {:error, _op, error, _changes}) do
    call(conn, {:error, error})
  end

  def call(conn, {:error, error}) do
    conn
    |> put_status(:unprocessable_entity)
    |> render_error(error)
  end

  def call(conn, term) do
    Logger.error("Unknown Value Recieved:")
    Logger.error(inspect(term))

    call(conn, {:error, :unknown_error})
  end



  # Private

  def normalize_changeset_errors(changeset) do
    Enum.map(changeset.errors, fn {type, {message, _details}} ->
      "#{type} #{message}"
    end)
  end

  defp render_error(conn, errors) when is_list(errors) do
    render(conn, Views.Fallback, :error, errors: errors)
  end

  defp render_error(conn, error) do
    render_error(conn, [error])
  end

end
