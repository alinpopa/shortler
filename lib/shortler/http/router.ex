defmodule Shortler.HTTP.Router do
  use Plug.Router
  alias Shortler.HTTP.Handler.{Fetch, Save, Track}

  plug(Plug.Logger)
  plug(:match)
  plug(:dispatch)

  get "/:key" do
    conn
    |> Fetch.handle(key)
    |> Track.handle()
  end

  post "/" do
    conn |> Save.handle()
  end

  match _ do
    send_resp(conn, 404, "")
  end
end
