defmodule Shortler.Store.CleanerTest do
  use ExUnit.Case
  doctest Shortler
  use Shortler.TestSetup
  alias Shortler.Store.Cleaner

  setup do
    Cleaner.swap_context(%Shortler.Test.Context{})
    :ok
  end

  test "swap context" do
    assert Cleaner.swap_context(%Shortler.Test.Context{}) == {:ok, %Shortler.Test.Context{}}
  end

  test "clean expired on demand" do
    task =
      Task.async(fn ->
        receive do
          :done -> :ok
        end
      end)

    Cleaner.swap_context(%Shortler.Test.Context{
      fun: fn ->
        send(task.pid, :done)
      end
    })

    Cleaner.cleanup()
    assert Task.await(task, 3000) == :ok
  end
end
