defmodule DBFS.Web.Views.API.V1.Fallback do
  use DBFS.Web, :view

  def render("error.json", %{errors: errors}) do
    %{status: :error, messages: errors}
  end
end
