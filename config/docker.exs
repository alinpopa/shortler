use Mix.Config
import_config "prod.exs"

config :shortler, Shortler.Store.Repo,
  hostname: "postgres"

config :shortler, Shortler.Clicks.Connection,
  host: "influxdb"
