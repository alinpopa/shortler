defmodule Shortler.Clicks.SenderTest do
  use ExUnit.Case
  doctest Shortler
  use Shortler.TestSetup
  alias Shortler.Clicks.Sender

  setup do
    Sender.swap_context(%Shortler.Test.Context{})
    :ok
  end

  test "swap context" do
    assert Sender.swap_context(%Shortler.Test.Context{}) == {:ok, %Shortler.Test.Context{}}
  end

  test "send data" do
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

    Sender.send(%{data: "test"})

    assert Task.await(task, 3000) == {:ok, %{data: "test"}}
  end
end
