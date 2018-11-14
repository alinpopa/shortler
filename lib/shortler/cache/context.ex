defmodule Shortler.Cache.Context do
  defstruct table_name: :urls_cache
end

defimpl Shortler.Store.GetUrl, for: Shortler.Cache.Context do
  def get_url(context, short),
    do: get_from_cache(context, short)

  defp get_from_cache(context, short),
    do: get_from_store(context, short, Shortler.Cache.EtsCache.get(short))

  defp get_from_store(_context, short, nil) do
    case Shortler.Store.GetUrl.get_url(%Shortler.Context{}, short) do
      nil ->
        nil

      url ->
        Shortler.Cache.EtsCache.put(short, url)
        url
    end
  end

  defp get_from_store(_context, _short, url), do: url
end

defimpl Shortler.Store.Clean, for: Shortler.Cache.Context do
  def clean_expired(_context) do
    deleted = Shortler.Store.Clean.clean_expired(%Shortler.Context{})

    case deleted do
      {0, _} ->
        []

      {_, urls} ->
        Enum.each(urls, fn url ->
          Shortler.Cache.EtsCache.remove(url.short)
        end)

        urls
    end
  end
end

defimpl Shortler.Cache.Ops, for: Shortler.Cache.Context do
  def init(context) do
    :ets.new(context.table_name, [:named_table, :set, read_concurrency: true])
    context
  end

  def get(context, key) do
    case :ets.lookup(context.table_name, key) do
      [] -> nil
      [{^key, value, _}] -> value
      _ -> nil
    end
  end

  def put(context, key, val) do
    expire = System.system_time(:second) + Shortler.Conf.cache_ttl_sec()
    :ets.insert(context.table_name, {key, val, expire})
    {:ok, key}
  end

  def remove(context, key) do
    :ets.delete(context.table_name, key)
    {:ok, key}
  end

  def expire(context) do
    now = System.system_time(:second)
    :ets.select_delete(context.table_name, [{{:"$1", :_, :"$2"}, [{:<, :"$2", now}], [true]}])
    :ok
  end
end

defimpl Shortler.Cache.Ops, for: Any do
  def init(_context) do
    Shortler.Cache.Ops.init(%Shortler.Cache.Context{})
  end

  def get(_context, key) do
    Shortler.Cache.Ops.get(%Shortler.Cache.Context{}, key)
  end

  def put(_context, key, val) do
    Shortler.Cache.Ops.put(%Shortler.Cache.Context{}, key, val)
  end

  def remove(_context, key) do
    Shortler.Cache.Ops.remove(%Shortler.Cache.Context{}, key)
  end

  def expire(_context) do
    Shortler.Cache.Ops.expire(%Shortler.Cache.Context{})
  end
end
