defmodule MeowCave.Member do
  # import Ecto.Query

  alias MeowCave.Repo
  alias MeowCave.Member.UserRepo
  alias Member.User

  @behaviour Member.User.Repo
  # 我很高兴一个模块可以继承多个行为

  @impl true
  def create(%User.Authentication{} = authentication_field, %User.Locale{} = locale_field) do
    user =
      UserRepo.from_domain(authentication_field, locale_field)
      |> UserRepo.changeset()

    case Repo.insert(user, on_conflict: :raise) do
      {:ok, user} ->
        {:ok, UserRepo.to_domain(user)}

      {:error, changeset} ->
        {:error, changeset}
        # Send it, and raise custom exception in usecase layer.
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
    update_changeset =
      Ecto.Changeset.cast(UserRepo.from_domain(targer_user), updated_items, @valid_fields)

    case Repo.update(update_changeset) do
      {:ok, user} -> {:ok, UserRepo.to_domain(user, locale, auth)}
      {:error, changeset} -> {:error, changeset}
    end
  end

  @impl true
  def get_user_by_id(id) do
    user_or_nil = MeowCave.Repo.get(UserRepo, id)

    if is_nil(user_or_nil) do
      nil
    else
      UserRepo.to_domain(user_or_nil)
    end
  end
end
