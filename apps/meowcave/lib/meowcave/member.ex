defmodule MeowCave.Member do
  # import Ecto.Query

  alias MeowCave.Repo
  alias MeowCave.Member.UserRepo
  alias Member.User

  @behaviour Member.User.Repo
  # 我很高兴一个模块可以继承多个行为

  @impl true
  def create(%User.Authentication{} = authentication_field, %User.Locale{} = locale_field) do
    UserRepo.from_domain(authentication_field, locale_field)
    |> Repo.insert!()
    |> UserRepo.to_domain()
  end
end
