defmodule DBFS.Web.Router do
  use DBFS.Web, :router


  # API Pipeline

  pipeline :api do
    plug :accepts, ["json"]
  end



  # API Routes

  scope "/", DBFS.Web.Controllers do
    scope "/api/v1", API.V1 do
      pipe_through :api


      get "/",  Main,   :index

      scope "/blocks" do
        post "/",       Block, :create
        get  "/:hash",  Block, :show
      end

    end
  end

end
