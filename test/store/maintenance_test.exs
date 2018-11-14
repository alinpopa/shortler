defmodule Shortler.Store.MaintenanceTest do
  use ExUnit.Case
  doctest Shortler
  use Shortler.TestSetup
  alias Shortler.Store.Maintenance

  setup do
    Maintenance.swap_context(%Shortler.Test.Context{})
    :ok
  end

  test "swap context" do
    assert Maintenance.swap_context(%Shortler.Test.Context{}) == {:ok, %Shortler.Test.Context{}}
  end

  test "update expire" do
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

    Maintenance.update_expire("short", "expire")
    assert Task.await(task, 3000) == {"short", "expire"}
  end
end
