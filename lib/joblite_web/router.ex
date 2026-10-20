defmodule JobliteWeb.Router do
  use Phoenix.Router
  import Plug.Conn
  import Phoenix.Controller
  import Phoenix.LiveView.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {JobliteWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", JobliteWeb do
    get "/health/live", HealthController, :live
    get "/health/ready", HealthController, :ready
  end

  scope "/", JobliteWeb do
    pipe_through :browser
    live "/", HomeLive
  end
end
