use Mix.Config

config :shortler, Shortler.Store.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "password",
  database: "shortler_dev",
  hostname: "localhost",
  pool_size: 10,
  timeout: 60_000

config :shortler, Shortler.Clicks.Connection,
  database: "shortler_clicks",
  host: "localhost",
  pool: [max_overflow: 10, size: 50],
  port: 8087,
  scheme: "http",
  writer: Instream.Writer.Line
