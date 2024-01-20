defmodule MeowCave.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :username, :string
      add :nickname, :string
      add :status, :string
      add :gender, :string
      add :gender_visible, :boolean, default: false, null: false
      add :info, :string
      add :join_at, :utc_datetime
      add :email, :string
      add :password, :string
      add :timezone, :string
      add :lang, :string

      timestamps()
    end
  end
end