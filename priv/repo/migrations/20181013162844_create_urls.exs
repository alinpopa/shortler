defmodule Shortler.Store.Repo.Migrations.CreateUrls do
  use Ecto.Migration

  def change do
    create table(:urls, primary_key: false) do
      add(:short, :string, primary_key: true)
      add(:orig, :string, null: false)
      add(:expire, :naive_datetime, null: false)
    end

    create(index("urls", [:expire]))
  end
end
