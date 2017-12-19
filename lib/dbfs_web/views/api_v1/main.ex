defmodule DBFS.Web.Views.API.V1.Main do
  use DBFS.Web, :view


  def render("index.json", %{status: status, nodes: nodes}) do
    Map.put(status, :nodes, nodes)
  end


  def render("nodes.json", %{nodes: nodes, block_count: count}) do
    %{nodes: nodes, block_count: count}
  end
end
