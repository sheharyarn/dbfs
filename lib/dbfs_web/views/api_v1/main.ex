defmodule DBFS.Web.Views.API.V1.Main do
  use DBFS.Web, :view

  def render("index.json", %{blockchain: blockchain}) do
    %{
      count: blockchain.count,
      recent: Enum.take(blockchain.chain, 5),
    }
  end
end
