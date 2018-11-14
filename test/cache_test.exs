defmodule Shortler.CacheTest do
  use ExUnit.Case
  doctest Shortler
  alias Shortler.Cache.EtsCache

  setup do
    EtsCache.swap_context(%Shortler.Test.Context{})
    :ok
  end

  test "should return the element that was previously added to cache" do
    task =
      Task.async(fn ->
        receive do
          {:value, value} -> value
        end
      end)

    context = %Shortler.Test.Context{
      fun: fn _k ->
        send(task.pid, {:value, "test value"})
      end
    }

    EtsCache.get("key", context)
    assert Task.await(task, 3000) == "test value"
  end

  test "should remove expired elements when expiration check runs" do
    task =
      Task.async(fn ->
        receive do
          :done -> :done
        end
      end)

    EtsCache.swap_context(%Shortler.Test.Context{
      fun: fn ->
        send(task.pid, :done)
      end
    })

    EtsCache.expire()
    assert Task.await(task, 3000) == :done
  end

  test "should write data to the backend when saving a value" do
    task =
      Task.async(fn ->
        receive do
          {:write, k, v} -> {k, v}
        end
      end)

    EtsCache.swap_context(%Shortler.Test.Context{
      fun: fn k, v ->
        send(task.pid, {:write, k, v})
      end
    })

    EtsCache.put("key0", "value0")
    assert Task.await(task, 3000) == {"key0", "value0"}
  end

  test "should return nothing when cache is empty" do
    task =
      Task.async(fn ->
        receive do
          {:get, v} -> v
        end
      end)

    context = %Shortler.Test.Context{
      fun: fn _k ->
        send(task.pid, {:get, nil})
      end
    }

    EtsCache.get("key0", context)
    assert Task.await(task, 3000) == nil
  end

  test "should update value in cache when exists" do
    task_get =
      Task.async(fn ->
        receive do
          {:get, v} -> v
        end
      end)

    task_save =
      Task.async(fn ->
        receive do
          {:save, k, v} -> {k, v}
        end
      end)

    EtsCache.swap_context(%Shortler.Test.Context{
      fun: fn k, v ->
        send(task_save.pid, {:save, k, v})
      end
    })

    get_context = %Shortler.Test.Context{
      fun: fn _k ->
        send(task_get.pid, {:get, "value0"})
        "value0"
      end
    }

    EtsCache.get("key0", get_context)
    assert Task.await(task_get, 3000) == "value0"
    assert Task.await(task_save, 3000) == {"key0", "value0"}
  end
end
