defmodule DBFS.Web.Views.API.V1.Block do
  use DBFS.Web, :view


  @pager_fields [:entries, :page_number, :total_entries, :total_pages]


  def render("index.json", %{pager: pager}) do
    Map.take(pager, @pager_fields)
  end


  def render("show.json", %{block: block}) do
    block
  end


end
