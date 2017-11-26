defmodule DBFS.Web.Views.API.V1.Main do
  use DBFS.Web, :view

  def render("index.json", %{blockchain: nil}) do
    %{
      status: :error,
      message: :doesnt_exist,
    }
  end


  def render("index.json", %{blockchain: blockchain}) do
    %{
      status: :success,
      count:  blockchain.count,
      recent: Enum.take(blockchain.chain, 5),
    }
  end
end
