defmodule MeowCave.Repo do
  use Ecto.Repo,
    otp_app: :meowcave,
    adapter: Ecto.Adapters.Postgres
end
