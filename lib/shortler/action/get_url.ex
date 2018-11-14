defmodule Shortler.Action.GetUrl do
  alias Shortler.Store.{GetUrl, Maintenance}
  alias Shortler.Template.Parse
  alias Shortler.Conf
  alias NaiveDateTime, as: Date

  def get(short, params, context \\ %Shortler.Context{}) do
    GetUrl.get_url(context, short)
    |> post_get(params, context)
  end

  defp post_get(nil, _params, _context), do: :not_found

  defp post_get(url, nil, _context) do
    Maintenance.update_expire(url.short, expire())
    {:ok, url.orig}
  end

  defp post_get(url, params, context) when is_map(params) do
    Maintenance.update_expire(url.short, expire())
    {:ok, Parse.parse(context, url.orig, params)}
  end

  defp expire(),
    do: Date.utc_now() |> Date.add(Conf.url_expiration_sec(), :second)
end
