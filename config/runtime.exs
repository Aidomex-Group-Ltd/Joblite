import Config

if config_env() == :prod do
  # DATABASE_SSL selects the PostgreSQL transport policy. The default
  # verify-full pins the server against a supplied CA bundle; managed platforms
  # that terminate database TLS without shipping a CA file (Render's managed
  # PostgreSQL) set DATABASE_SSL=require, which keeps the connection encrypted
  # without certificate pinning. An unknown value fails the boot instead of
  # silently downgrading.
  database_ssl =
    case System.get_env("DATABASE_SSL", "verify-full") do
      "verify-full" ->
        [
          verify: :verify_peer,
          cacertfile: System.fetch_env!("DATABASE_CA_CERT"),
          server_name_indication:
            String.to_charlist(System.fetch_env!("DATABASE_SSL_SERVER_NAME"))
        ]

      "require" ->
        [verify: :verify_none]

      "disable" ->
        false

      other ->
        raise "unsupported DATABASE_SSL value: #{inspect(other)} " <>
                "(expected verify-full | require | disable)"
    end

  config :joblite_core, Joblite.Repo,
    url: System.fetch_env!("DATABASE_URL"),
    pool_size: String.to_integer(System.get_env("POOL_SIZE", "5")),
    ssl: database_ssl

  # The one-off maintenance image (joblite-backend) sets JOBLITE_ROLE=maintenance:
  # it runs release commands such as migrations and never boots the endpoint, so
  # endpoint-only secrets (PHX_HOST, SECRET_KEY_BASE, PORT) are demanded from the
  # web role alone. Production deployments never set this variable on the web tier.
  if System.get_env("JOBLITE_ROLE", "web") != "maintenance" do
    host = System.fetch_env!("PHX_HOST")

    config :joblite_web, JobliteWeb.Endpoint,
      server: true,
      url: [scheme: "https", host: host, port: 443],
      http: [ip: {0, 0, 0, 0}, port: String.to_integer(System.get_env("PORT", "4000"))],
      check_origin: ["https://#{host}"],
      secret_key_base: System.fetch_env!("SECRET_KEY_BASE")
  end
end
