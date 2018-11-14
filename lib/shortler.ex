defmodule Shortler do
  @moduledoc false
  use Application
  require Logger
  alias Shortler.Conf

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    http_port = Conf.http_port()

    children = [
      supervisor(Shortler.Store.Repo, []),
      {Shortler.Cache.EtsCache, Conf.context()},
      {Shortler.Store.Maintenance, Conf.context()},
      %{
        id: Shortler.Store.Cleaner,
        start: {Shortler.Store.Cleaner, :start_link, [Conf.context()]}
      },
      Shortler.Clicks.Connection,
      {Shortler.Clicks.Sender, Conf.context()},
      {Plug.Adapters.Cowboy2,
       scheme: :http, plug: Shortler.HTTP.Router, options: [port: http_port]}
    ]

    Logger.info("HTTP listener started on #{http_port}")

    opts = [strategy: :one_for_one, name: Shortler.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
