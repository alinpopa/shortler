use Mix.Config
import System, only: [get_env: 1]

config :logger,
  backends: [:console],
  level: :info,
  compile_time_purge_matching: [
    [level_lower_than: :info]
  ]

config :shortler,
  http_port: get_env("PORT") || 8888,
  url_prefix: get_env("URL_PREFIX") || "http://localhost:8888",
  url_expiration_sec: 2_592_000,
  ecto_repos: [Shortler.Store.Repo]

config :shortler, Shortler.Store.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "password",
  database: "shortler_prod",
  hostname: "localhost",
  pool_size: 10,
  timeout: 60_000

config :shortler, Shortler.Clicks.Connection,
  database: "shortler_clicks",
  host: "localhost",
  pool: [max_overflow: 10, size: 50],
  port: 8086,
  scheme: "http",
  writer: Instream.Writer.Line
