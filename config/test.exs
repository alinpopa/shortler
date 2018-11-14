use Mix.Config
import System, only: [get_env: 1]

config :logger,
  backends: [:console],
  level: :warn,
  compile_time_purge_matching: [
    [level_lower_than: :warn]
  ]

config :shortler, Shortler.Store.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "password",
  database: "shortler_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  timeout: 60_000

config :shortler,
  context: Shortler.Test.Context
