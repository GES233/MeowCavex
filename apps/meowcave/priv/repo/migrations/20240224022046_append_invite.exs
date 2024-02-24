defmodule MeowCave.Repo.Migrations.AppendInvite do
  use Ecto.Migration

  def change do
    create table(:invite) do
      add :code, :string
      add :status, :string
      add :create_at, :utc_datetime
      add :expire, :time
      add :host_id, references(:users)
      add :guest_id, references(:users)

      # No timesteps required.
    end

    create unique_index(:invite, [:code])
    create unique_index(:invite, [:host_id, :guest_id])
  end
end
