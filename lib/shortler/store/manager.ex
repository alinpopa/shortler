defmodule Shortler.Store.Manager do
  alias Shortler.Store.{Repo, Url}

  def save_url(data = %{orig: url, short: short, expire: %NaiveDateTime{}})
      when is_binary(url) and is_binary(short) do
    %Url{}
    |> Url.changeset(data)
    |> Repo.insert(on_conflict: :replace_all, conflict_target: [:short])
    |> post_insert()
  end

  def get_url(nil), do: nil

  def get_url(short) do
    import Ecto.Query, only: [from: 2]

    from(u in Url,
      where: u.short == ^short,
      select: u
    )
    |> Repo.one()
  end

  def update_expire(short, expire = %NaiveDateTime{}) do
    import Ecto.Query, only: [from: 2]

    from(u in Url,
      where: u.short == ^short
    )
    |> Repo.update_all(set: [expire: expire])
  end

  def clean_expired() do
    import Ecto.Query, only: [from: 2]
    now = NaiveDateTime.utc_now()

    from(u in Url,
      where: u.expire <= ^now
    )
    |> Repo.delete_all(returning: [:short])
  end

  defp post_insert({:error, changeset}),
    do: {:error, changeset.errors}

  defp post_insert({:ok, url}),
    do: {:ok, url.short}
end
