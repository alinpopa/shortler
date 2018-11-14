defmodule Shortler.Store.Url do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "urls" do
    field(:short, :string)
    field(:orig, :string)
    field(:expire, :naive_datetime)
  end

  def changeset(url, params \\ %{}) do
    url
    |> cast(params, [:short, :orig, :expire])
    |> validate_required([:short, :orig, :expire])
    |> validate_length(:short, max: 11)
    |> validate_length(:orig, max: 255)
    |> unique_constraint(:short, name: :urls_pkey)
  end
end
