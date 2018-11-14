defmodule Shortler.Action.GetUrlTest do
  use ExUnit.Case
  doctest Shortler
  use Shortler.TestSetup
  alias Shortler.Store.{Repo, Maintenance}
  alias Shortler.Action.GetUrl
  alias NaiveDateTime, as: Date

  setup do
    Maintenance.swap_context(%Shortler.Test.Context{})
    :ok
  end

  test "should return not found when no url mappings exists" do
    assert GetUrl.get("non existing short", nil) == :not_found
  end

  test "should return existing mapped url when found" do
    %Shortler.Store.Url{}
    |> Shortler.Store.Url.changeset(%{orig: "o1", short: "s1", expire: Date.utc_now()})
    |> Repo.insert()

    assert GetUrl.get("s1", nil) == {:ok, "o1"}
  end

  test "should update the expiration date for an url on click" do
    expire = Date.utc_now()

    %Shortler.Store.Url{}
    |> Shortler.Store.Url.changeset(%{orig: "o1", short: "s1", expire: expire})
    |> Repo.insert()

    task =
      Task.async(fn ->
        receive do
          {:done, s, e} -> {s, e}
        end
      end)

    Maintenance.swap_context(%Shortler.Test.Context{
      fun: fn s, e ->
        send(task.pid, {:done, s, e})
      end
    })

    {:ok, "o1"} = GetUrl.get("s1", nil)
    {_short, e} = Task.await(task, 3000)
    assert Date.compare(e, expire) == :gt
  end
end
