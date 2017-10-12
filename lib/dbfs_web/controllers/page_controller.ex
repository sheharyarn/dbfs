defmodule DBFS.Web.PageController do
  use DBFS.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
