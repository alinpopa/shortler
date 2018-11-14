defmodule Shortler.Action.SaveUrlTest do
  use ExUnit.Case
  doctest Shortler
  use Shortler.TestSetup
  alias Shortler.Store.Repo
  alias Shortler.Action.SaveUrl
  alias NaiveDateTime, as: Date

  test "should validate the given url" do
    assert SaveUrl.save(nil) == {:error, :invalid_url}
  end

  test "should successfully return the shortened url using a hash when the given url is valid" do
    Application.put_env(:shortler, :url_prefix, "prefix")
    assert SaveUrl.save("valid_value") == {:ok, "prefix/Mn8-M9v-a-h"}
  end

  test "should save the given url together with an expiration date" do
    import Ecto.Query, only: [from: 2]
    Application.put_env(:shortler, :url_prefix, "")
    Application.put_env(:shortler, :url_expiration_sec, 0)
    {:ok, short} = SaveUrl.save("valid_value")
    short = String.replace_leading(short, "/", "")

    result =
      from(u in Shortler.Store.Url,
        where: u.short == ^short,
        select: u
      )
      |> Repo.one()

    assert result.orig == "valid_value"
    assert Date.compare(result.expire, Date.utc_now()) == :lt
  end
end
