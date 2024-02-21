defmodule MeowCave.Repo.Migrations.AddUserTokens do
  use Ecto.Migration

  def change do
    create table(:user_tokens) do
      add :users_id, references(:users, on_delete: :delete_all), null: false
      add :token, :binary, null: false
      add :context, :map, null: true
      add :scope, :string, null: false
      add :sent_to, :string

      timestamps(updated_at: false)
    end

    create index(:user_tokens, [:users_id])
    create unique_index(:user_tokens, [:context, :scope, :token])
  end
end
