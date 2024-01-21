defmodule MeowCave.Member do
  # import Ecto.Query

  alias MeowCave.Repo
  alias MeowCave.Member.UserRepo
  alias Member.User

  @behaviour Member.User.Repo
  # 我很高兴一个模块可以继承多个行为

  @impl true
  def create(%User.Authentication{} = authentication_field, %User.Locale{} = locale_field) do
    {status, user_or_changeset} =
      UserRepo.from_domain(authentication_field, locale_field)
      |> Repo.insert()
      # insert 的默认设置的 :on_conflict 为 :raise
      # 最好改为 :ignore

    case status do
      :ok -> {:ok, user_or_changeset |> UserRepo.to_domain()}
      :error -> {:error, user_or_changeset}
    end
  end

  @valid_fields [
      :username,
      :nickname,
      :status,
      :gender,
      :gender_visible,
      :info,
      :email,
      :password,
      :timezone,
      :lang
  ]

  @impl true
  def update_user_info(%User{} = targer_user, updated_items, locale, auth) do
    changeset = Ecto.Changeset.cast(UserRepo.from_domain(targer_user), updated_items, @valid_fields)

    {status, user_or_changeset} =
      changeset
      |> Repo.update()

    case status do
      :ok -> {:ok, user_or_changeset |> UserRepo.to_domain(locale, auth)}
      :error -> {:error, user_or_changeset}
    end
  end
end
