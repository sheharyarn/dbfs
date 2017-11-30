defmodule DBFS.Web.Views.API.V1.Fallback do
  use DBFS.Web, :view

  def render("error.json", %{error: error}) do
    %{status: :error, message: error}
  end
end
