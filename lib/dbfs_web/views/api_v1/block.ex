defmodule DBFS.Web.Views.API.V1.Block do
  use DBFS.Web, :view

  def render("show.json", %{block: block}) do
    block
  end
end
