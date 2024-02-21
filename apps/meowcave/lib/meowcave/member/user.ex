defmodule MeowCave.Member.UserRepo do
  @moduledoc """
  俺也不知道咋写。
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias Ecto.Enum

  alias Member.User

  schema "users" do
    # from Member.User
    field :username, :string
    field :nickname, :string
    field :status, Enum, values: [:normal, :deleted, :freeze, :blocked, :newbie]
    field :gender, Enum, values: [:male, :female, :non_bisexual, :blank]
    field :gender_visible, :boolean, default: false
    field :info, :string
    field :join_at, :utc_datetime
    # from Member.User.Authentication
    field :email, :string
    field :password, :string, redact: true
    # from Member.User.Locale
    field :timezone, :string
    field :lang, :string

    timestamps()
  end

  ## Changeset

  defp changeset_prelude(%__MODULE__{} = user, attrs) do
    cast(user, attrs, [
      :username,
      :nickname,
      :status,
      :gender,
      :gender_visible,
      :info,
      :join_at,
      :email,
      :password,
      :timezone,
      :lang
    ])
  end

  defp changeset_prelude(%Ecto.Changeset{} = changeset, _attrs), do: changeset

  def create_user_changeset(user, attrs \\ %{}) do
    user
    |> changeset_prelude(attrs)
    |> unique_constraint([:email], message: "has already been taken")
    |> set_anomynous_nickname()
  end

  def set_anomynous_nickname(changeset) do
    name = get_field(changeset, :nickname)

    if is_nil(name) do
      put_change(changeset, :nickname, "Anomynous Member")
    else
      changeset
    end
  end

  def update_changeset(user, updated_items) do
    user
    |> changeset_prelude(updated_items)
  end

  ## Application related.

  # DTO -> DAO
  def from_domain(%User.Authentication{} = auth_field, %User.Locale{} = locale) do
    %__MODULE__{
      username: nil,
      nickname: auth_field.nickname,
      status: User.Status.create() |> User.Status.value(),
      gender: User.Gender.create() |> User.Gender.value(),
      gender_visible: not (User.Gender.create() |> User.Gender.secret?()),
      join_at: DateTime.utc_now(:second),
      email: auth_field.email,
      password: auth_field.hashed_password,
      timezone: locale.timezone,
      lang: locale.lang
    }
  end

  # Domain -> DTO
  def from_domain(%User{} = user) do
    %__MODULE__{
      id: user.id,
      username: user.username,
      nickname: user.nickname,
      status: User.Status.value(user.status),
      gender: User.Gender.value(user.gender),
      gender_visible: not User.Gender.secret?(user.gender),
      join_at: user.join_at,
      info: user.info
    }
  end

  def to_domain(%__MODULE__{} = dao, locale \\ false, auth \\ false) do
    case {locale, auth} do
      {false, false} ->
        %User{
          id: dao.id,
          username: dao.username,
          nickname: dao.nickname,
          gender: %User.Gender{
            value: dao.gender,
            hidden: not dao.gender_visible
          },
          status: %User.Status{
            value: dao.status
          },
          info: dao.info,
          join_at: dao.join_at
        }

      {true, false} ->
        %User.Locale{
          id: dao.id,
          lang: dao.lang,
          timezone: dao.timezone
        }

      {false, true} ->
        %User.Authentication{
          id: dao.id,
          nickname: dao.nickname,
          email: dao.email,
          hashed_password: dao.password
        }

      {true, true} ->
        nil
    end
  end
end

defmodule MeowCave.Member.User.PassHash do
  @behaviour Member.Service.Password

  def generate_hash(password) do
    Pbkdf2.hash_pwd_salt(password)
  end

  def verify_pswd(password, hash) do
    Pbkdf2.verify_pass(password, hash)
  end
end
