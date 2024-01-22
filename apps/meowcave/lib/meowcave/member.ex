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
    case status do
      :ok -> {:ok, user_or_changeset |> UserRepo.to_domain()}
      :error -> {:error, user_or_changeset}
    end
  end

  @valid_fields [
    # 参见 MeowCave.Member.User 的那些 fields
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
    changeset =
      Ecto.Changeset.cast(UserRepo.from_domain(targer_user), updated_items, @valid_fields)

    {status, user_or_changeset} =
      changeset
      |> Repo.update()

    case status do
      :ok -> {:ok, user_or_changeset |> UserRepo.to_domain(locale, auth)}
      :error -> {:error, user_or_changeset}
    end
  end

  @impl true
  def get_user_by_id(id) do
    user_or_nil = MeowCave.Repo.get(UserRepo, id)

    if is_nil(user_or_nil) do
      nil
    else
      user_or_nil |> UserRepo.to_domain()
    end
  end
end
