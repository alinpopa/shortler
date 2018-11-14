defmodule Shortler.HTTP.Handler.Save do
  alias Shortler.Action.SaveUrl, as: Action
  alias Plug.Conn

  @context Shortler.Conf.context()

  def handle(conn) do
    {:ok, url, conn} = conn |> Conn.read_body()

    Action.save(url, @context)
    |> resp(conn)
  end

  defp resp({:error, reason}, conn),
    do: conn |> Conn.resp(400, reason)

  defp resp({:ok, short}, conn),
    do: conn |> Conn.resp(201, short)
end
