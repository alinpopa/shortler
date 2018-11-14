defmodule Shortler.Conf do
  @app_name :shortler

  def http_port(),
    do: get(:http_port, :int)

  def url_expiration_sec(),
    do: get(:url_expiration_sec, :int)

  def url_prefix(),
    do: get(:url_prefix, :str)

  def context(),
    do: get(:context, :struct)

  def cleanup_ms(),
    do: get(:cleanup_ms, :int)

  def cache_ttl_sec(),
    do: get(:cache_ttl_sec, :int)

  def cache_expire_frequency_sec(),
    do: get(:cache_expire_frequency_sec, :int)

  defp get(key, type),
    do:
      Application.get_env(@app_name, key)
      |> get_as(type)

  defp get_as(value, :int) when is_binary(value),
    do: String.to_integer(value)

  defp get_as(value, :str) when is_binary(value),
    do: value

  defp get_as(value, :str),
    do: inspect(value)

  defp get_as(value, :struct) when not is_nil(value) and is_atom(value),
    do: struct(value)

  defp get_as(value, _type),
    do: value
end
