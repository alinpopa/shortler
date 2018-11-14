defmodule Shortler.Store.ManagerTest do
  use ExUnit.Case, async: true
  doctest Shortler
  use Shortler.TestSetup
  alias Shortler.Store.Manager
  alias Shortler.Store.Repo
  alias NaiveDateTime, as: Date

  describe "save url" do
    test "should save only valid urls" do
      assert_raise FunctionClauseError, fn ->
        Manager.save_url("invalid url")
      end

      assert_raise FunctionClauseError, fn ->
        Manager.save_url(%{url: "test", short: "short", expire: "tomorrow"})
      end

      assert_raise FunctionClauseError, fn ->
        Manager.save_url(%{url: "test", short: "short", expire: Date.utc_now()})
      end
    end

    test "should successfully try to save valid url data" do
      save_url = Manager.save_url(%{orig: "test", short: "short", expire: Date.utc_now()})

      assert save_url == {:ok, "short"}
    end

    test "should persist saved url data" do
      import Ecto.Query, only: [from: 2]
      expire = Date.utc_now()
      Manager.save_url(%{orig: "test", short: "short", expire: expire})

      result =
        from(u in Shortler.Store.Url,
          where: u.short == "short",
          select: u
        )
        |> Repo.one()

      assert result.orig == "test"
      assert Date.compare(result.expire, expire) == :eq
    end

    test "should refresh the expiration date when trying to save the same url data twice" do
      import Ecto.Query, only: [from: 2]
      expire1 = Date.utc_now()
      Manager.save_url(%{orig: "test", short: "short", expire: expire1})
      expire2 = Date.add(Date.utc_now(), 3600, :second)
      Manager.save_url(%{orig: "test", short: "short", expire: expire2})

      result =
        from(u in Shortler.Store.Url,
          where: u.short == "short",
          select: u
        )
        |> Repo.one()

      assert result.orig == "test"
      assert Date.compare(result.expire, expire2) == :eq
    end
  end

  describe "get url" do
    test "should return nil when passing a nil key" do
      assert Manager.get_url(nil) == nil
    end

    test "should return saved url data" do
      expire1 = Date.utc_now()

      %Shortler.Store.Url{}
      |> Shortler.Store.Url.changeset(%{orig: "test1", short: "s1", expire: expire1})
      |> Repo.insert()

      result = Manager.get_url("s1")
      assert result.orig == "test1"
      assert Date.compare(result.expire, expire1) == :eq
    end
  end

  describe "update expire" do
    test "should not do anything if short url doesn't exist" do
      import Ecto.Query, only: [from: 2]
      assert Manager.update_expire("invalid short url", Date.utc_now()) == {0, nil}

      result =
        from(u in Shortler.Store.Url,
          where: u.short == "invalid short url",
          select: u
        )
        |> Repo.one()

      assert result == nil
    end

    test "should update the expiration date of an existing short url" do
      import Ecto.Query, only: [from: 2]
      expire1 = Date.utc_now()

      %Shortler.Store.Url{}
      |> Shortler.Store.Url.changeset(%{orig: "test1", short: "s1", expire: expire1})
      |> Repo.insert()

      five_seconds_later = Date.add(expire1, 100, :second)

      Manager.update_expire("s1", five_seconds_later)

      result =
        from(u in Shortler.Store.Url,
          where: u.short == "s1",
          select: u
        )
        |> Repo.one()

      assert Date.compare(result.expire, five_seconds_later) == :eq
    end
  end

  describe "clean expired" do
    test "should not remove urls that are not expired yet" do
      import Ecto.Query, only: [from: 2]
      expire_tomorrow = Date.add(Date.utc_now(), 86400, :second)

      %Shortler.Store.Url{}
      |> Shortler.Store.Url.changeset(%{orig: "test1", short: "s1", expire: expire_tomorrow})
      |> Repo.insert()

      Manager.clean_expired()

      result =
        from(u in Shortler.Store.Url,
          where: u.short == "s1",
          select: u
        )
        |> Repo.one()

      assert Date.compare(result.expire, expire_tomorrow) == :eq
    end

    test "should a single expired url" do
      import Ecto.Query, only: [from: 2]
      expired_5_seconds_ago = Date.add(Date.utc_now(), -5, :second)
      expire_tomorrow = Date.add(Date.utc_now(), 86400, :second)

      %Shortler.Store.Url{}
      |> Shortler.Store.Url.changeset(%{orig: "test1", short: "s1", expire: expired_5_seconds_ago})
      |> Repo.insert()

      %Shortler.Store.Url{}
      |> Shortler.Store.Url.changeset(%{orig: "test2", short: "s2", expire: expire_tomorrow})
      |> Repo.insert()

      Manager.clean_expired()

      result =
        from(u in Shortler.Store.Url,
          where: u.short == "s1",
          select: u
        )
        |> Repo.one()

      assert result == nil

      result =
        from(u in Shortler.Store.Url,
          where: u.short == "s2",
          select: u
        )
        |> Repo.one()

      assert Date.compare(result.expire, expire_tomorrow) == :eq
    end

    test "should remove all expired urls" do
      import Ecto.Query, only: [from: 2]
      expired_5_seconds_ago = Date.add(Date.utc_now(), -5, :second)
      expired_3_seconds_ago = Date.add(Date.utc_now(), -3, :second)

      %Shortler.Store.Url{}
      |> Shortler.Store.Url.changeset(%{orig: "test1", short: "s1", expire: expired_5_seconds_ago})
      |> Repo.insert()

      %Shortler.Store.Url{}
      |> Shortler.Store.Url.changeset(%{orig: "test2", short: "s2", expire: expired_3_seconds_ago})
      |> Repo.insert()

      Manager.clean_expired()

      result =
        from(u in Shortler.Store.Url,
          where: u.short in ["s1", "s2"],
          select: u
        )
        |> Repo.all()

      assert result == []
    end
  end
end
