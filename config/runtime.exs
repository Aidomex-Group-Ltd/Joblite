import Config

if config_env() == :prod do
  host = System.fetch_env!("PHX_HOST")

  config :joblite_core, Joblite.Repo,
    url: System.fetch_env!("DATABASE_URL"),
    pool_size: String.to_integer(System.get_env("POOL_SIZE", "5")),
    ssl: [
      verify: :verify_peer,
      cacertfile: System.fetch_env!("DATABASE_CA_CERT"),
      server_name_indication: String.to_charlist(System.fetch_env!("DATABASE_SSL_SERVER_NAME"))
    ]

  config :joblite_web, JobliteWeb.Endpoint,
    server: true,
    url: [scheme: "https", host: host, port: 443],
    http: [ip: {0, 0, 0, 0}, port: String.to_integer(System.get_env("PORT", "4000"))],
    check_origin: ["https://#{host}"],
    secret_key_base: System.fetch_env!("SECRET_KEY_BASE")
end
