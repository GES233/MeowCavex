defmodule MeowCave.Member do
  # import Ecto.Query

  alias MeowCave.Repo
  alias MeowCave.Member.UserRepo
  alias Member.User

  @behaviour Member.User.Repo
  # 我很高兴一个模块可以继承多个行为

  @impl true
  def create(%User.Authentication{} = authentication_field, %User.Locale{} = locale_field) do
    {status, user_or_changeset} = UserRepo.from_domain(authentication_field, locale_field)
    |> Repo.insert()

    case status do
      :ok -> {:ok, user_or_changeset |> UserRepo.to_domain()}
      :error -> {:error, user_or_changeset}
    end
  end
end
