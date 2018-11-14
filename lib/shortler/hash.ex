defmodule Shortler.Hash do
  def hash(value) when is_binary(value),
    do:
      :crypto.hash(:sha, value)
      |> Base.url_encode64()
      |> String.slice(1..11)
end
