defmodule DBFS.Web.Views.API.V1.Main do
  use DBFS.Web, :view


  def render("index.json", %{status: status}) do
    status
  end
end
