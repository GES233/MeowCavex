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

  @impl true
  def update_user_info(%User{} = targer_user, [head | tail] = updated_items)
      when is_list(updated_items) do
    {k, v} = head
    # Use recursion.
    {status, new_user_or_error} = User.update(targer_user, k, v)

    case status do
      :ok -> update_user_info(new_user_or_error, tail)
      :error -> {:error, new_user_or_error}
    end
  end

  def update_user_info(%User{} = targer_user, []), do: targer_user |> update_user()

  def update_user_info(%User{} = _targer_user, updated_items)
      when is_map(updated_items) do
    # ...
  end

  def update_user_info(%User{} = targer_user, %{}), do: targer_user |> update_user()

  def update_user_info(_targer_user, _updated_items) do
    # TODO: raise error
  end

  @impl true
  def update_user_info(%User{} = target_user, updated_field, updated_value) do
    updated_single_item(target_user, updated_field, updated_value) |> update_user()
  end

  defp updated_single_item(%User{} = target_user, updated_field, updated_value) do
    User.update(target_user, updated_field, updated_value)
  end

  defp update_user(%User{} = new_user) do
    {status, user_or_changeset} =
      UserRepo.from_domain(new_user)
      |> Repo.update()

    case status do
      :ok -> {:ok, user_or_changeset |> UserRepo.to_domain()}
      :error -> {:error, user_or_changeset}
    end
  end
end
