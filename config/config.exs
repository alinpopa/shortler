use Mix.Config
import System, only: [get_env: 1]

config :logger, :console, format: "$time $metadata[$level] $message\n"

config :shortler,
  http_port: 8888,
  url_prefix: "http://localhost:8888",
  url_expiration_sec: 2_592_000,
  cleanup_ms: 60000,
  ecto_repos: [Shortler.Store.Repo],
  context: Shortler.Cache.Context,
  cache_ttl_sec: 300,
  cache_expire_frequency_sec: 60

config :shortler, Shortler.Clicks.Connection, []

import_config "#{Mix.env()}.exs"
