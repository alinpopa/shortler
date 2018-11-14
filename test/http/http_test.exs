defmodule Shortler.HTTP.HttpTest do
  use ExUnit.Case
  doctest Shortler
  use Plug.Test
  use Shortler.TestSetup
  alias Shortler.Clicks.Sender

  setup do
    Sender.swap_context(%Shortler.Test.Context{})
    :ok
  end

  test "returns 404 when using wrong resource" do
    conn = conn(:get, "/")
    conn = Shortler.HTTP.Router.call(conn, [])
    assert conn.status == 404
  end

  test "returns 404 when trying to access a non-existing short url" do
    conn = conn(:get, "/some-non-existing-url")
    conn = Shortler.HTTP.Router.call(conn, [])
    assert conn.status == 404
  end

  test "should successfully create a given url" do
    Application.put_env(:shortler, :url_prefix, "")
    conn = conn(:post, "/", "some url")
    conn = Shortler.HTTP.Router.call(conn, [])
    assert conn.status == 201
    assert conn.resp_body == "/INNrKVRDDKc"
  end

  test "should successfully redirect when clicking an existing short url" do
    Application.put_env(:shortler, :url_prefix, "")
    conn = conn(:post, "/", "some url")
    conn = Shortler.HTTP.Router.call(conn, [])
    short_url = conn.resp_body

    conn = conn(:get, short_url)
    conn = Shortler.HTTP.Router.call(conn, [])
    assert conn.status == 302
    assert Plug.Conn.get_resp_header(conn, "location") == ["some url"]
  end

  test "should track clicks only accessing existing short urls" do
    Application.put_env(:shortler, :url_prefix, "")
    conn = conn(:post, "/", "some url")
    conn = Shortler.HTTP.Router.call(conn, [])
    short_url = conn.resp_body

    task =
      Task.async(fn ->
        receive do
          {:sent, data} -> {:ok, data}
        end
      end)

    Sender.swap_context(%Shortler.Test.Context{
      fun: fn data ->
        send(task.pid, {:sent, data})
      end
    })

    conn = conn(:get, short_url) |> put_req_header("name", "test123")
    Shortler.HTTP.Router.call(conn, [])
    assert {:ok, %{"url" => _, "name" => "test123"}} = Task.await(task, 3000)
  end
end
