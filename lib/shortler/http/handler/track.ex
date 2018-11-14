defmodule Shortler.HTTP.Handler.Track do
  alias Plug.Conn
  alias Shortler.Clicks.Sender

  def handle(conn = %Conn{status: 404}), do: conn

  def handle(conn) do
    Enum.into(conn.req_headers, %{})
    |> Map.put("url", Conn.request_url(conn))
    |> Sender.send()

    conn
  end
end
