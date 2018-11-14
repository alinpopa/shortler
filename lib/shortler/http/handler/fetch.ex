defmodule Shortler.HTTP.Handler.Fetch do
  alias Shortler.Action.GetUrl, as: Action
  alias Plug.Conn

  @context Shortler.Conf.context()

  def handle(conn, nil),
    do: not_found(conn)

  def handle(conn, key) do
    conn = Conn.fetch_query_params(conn)

    Action.get(key, conn.params, @context)
    |> response(conn)
  end

  defp response(:not_found, conn),
    do: not_found(conn)

  defp response({:ok, url}, conn),
    do: redirect(conn, url)

  defp redirect(conn, url),
    do:
      conn
      |> Conn.put_resp_header("location", url)
      |> Conn.resp(302, "")

  defp not_found(conn),
    do: conn |> Conn.resp(404, "")
end
