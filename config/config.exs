import Config
import_config "../../backend/config/shared.exs"

config :phoenix, :json_library, Jason
config :joblite_web, :secure_cookies, config_env() == :prod

config :joblite_web, JobliteWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  pubsub_server: Joblite.PubSub,
  render_errors: [formats: [html: JobliteWeb.ErrorHTML], layout: false],
  live_view: [signing_salt: "joblite-live-v1"]

config :esbuild,
  version: "0.25.5",
  default: [
    args: ~w(js/app.js --bundle --target=es2022 --outdir=../priv/static/assets),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

import_config "#{config_env()}.exs"
