defmodule Shortler.Action.SaveUrl do
  alias Shortler.{Conf, Hash}
  alias Shortler.Store.SaveUrl
  alias NaiveDateTime, as: Date
  require Logger

  def save(url, context \\ %Shortler.Context{})

  def save(nil, _context),
    do: {:error, :invalid_url}

  def save(url, context) do
    %{expire: expire(), orig: url, short: Hash.hash(url)}
    |> save_url(context)
    |> post_save()
  end

  defp expire(),
    do: Date.utc_now() |> Date.add(Conf.url_expiration_sec(), :second)

  defp save_url(data, context),
    do: SaveUrl.save_url(context, data)

  defp post_save({:error, reason}) do
    Logger.warn("Failed saving the url: #{inspect(reason)}")
    {:error, "#{inspect(reason)}"}
  end

  defp post_save({:ok, short}) do
    url_prefix = Conf.url_prefix()
    {:ok, "#{url_prefix}/#{short}"}
  end
end
