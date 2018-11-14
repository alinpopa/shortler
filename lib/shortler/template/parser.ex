defmodule Shortler.Template.Parser do
  @match ~r/<%([a-zA-Z0-9]+)%>/

  def parse(str, nil), do: str

  def parse(str, params) when is_map(params) do
    Regex.scan(@match, str)
    |> Enum.reduce(str, fn [to_replace, key], acc ->
      case Map.get(params, key) do
        nil -> acc
        value -> String.replace(acc, to_replace, value)
      end
    end)
  end
end
