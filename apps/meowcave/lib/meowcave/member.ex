defmodule MeowCave.Member do
  # import Ecto.Query

  alias MeowCave.Repo
  alias MeowCave.Member.UserRepo
  alias Member.User

  @behaviour Member.User.Repo
  # 我很高兴一个模块可以继承多个行为

  # TODO: refrac with Ecto.Changeset.traverse_errors/2

  @impl true
  def create(%User.Authentication{} = authentication_field, %User.Locale{} = locale_field) do
    user =
      UserRepo.from_domain(authentication_field, locale_field)
      |> UserRepo.create_user_changeset()

    case Repo.insert(user, on_conflict: :raise) do
      {:ok, user} ->
        {:ok, UserRepo.to_domain(user)}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  @impl true
  def update_user_info(%User{} = targer_user, updated_items, locale, auth) do
    update_changeset =
      targer_user
      |> UserRepo.from_domain()
      |> UserRepo.update_changeset(updated_items |> update_if_status)

    case Repo.update(update_changeset) do
      {:ok, user} -> {:ok, UserRepo.to_domain(user, locale, auth)}
      {:error, changeset} -> {:error, changeset}
    end
  end

  defp update_if_status(%{status: %User.Status{} = status} = items),
    do: %{items | status: User.Status.value(status)}

  defp update_if_status(item), do: item

  @impl true
  def update_user_gender(%User{} = user, %User.Gender{} = new_gender) do
    changeset =
      user
      |> UserRepo.from_domain()
      |> UserRepo.update_gender_changeset(%{
        gender: new_gender.value,
        gender_visible: not new_gender.hidden
      })

    case Repo.update(changeset) do
      {:ok, user} -> {:ok, UserRepo.to_domain(user, false, false)}
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

  # 我有预感这玩意会写的又臭又长（
  ## 关于邀请
  @behaviour Member.Invite.Repo
  alias Member.{Invite, InviteCode}

  @impl true
  def append_invitation_code(%User{} = _user, %InviteCode{} = _code, _timestep) do
    {:ok, nil}
  end

  @impl true
  def check_invitation_code(%InviteCode{} = _code) do
    {:ok, nil}
  end

  @impl true
  def append_invite(%User{} = _host, %User{} = _guest) do
    %Invite{}
  end

  @impl true
  def verify_invite(%User{} = _host, %User{} = _guest) do
    {:ok, true}
  end

  @impl true
  def get_host(%User{} = _user, _depth \\ 0) do
    {:ok, %{1 => [], 2 => []}}
  end

  @impl true
  def get_guests(%User{} = _user, _depth \\ 0) do
    {:ok, %{1 => [], 2 => []}}
  end

  @impl true
  def get_last_invite_code(%User{} = _user) do
    {:ok, %InviteCode{}}
  end

  @impl true
  def get_invite_code(%User{} = _user) do
    {:ok, %InviteCode{}}
  end
end
