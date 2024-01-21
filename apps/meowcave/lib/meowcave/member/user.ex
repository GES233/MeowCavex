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

  def changeset(user, attrs) do
    user
    |> cast(attrs, [
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
    |> unique_constraint([:email])
    |> set_anomynous_nickname()
  end

  def set_anomynous_nickname(changeset) do
    name = get_field(changeset, :nickname)

    if is_nil(name) do
      put_change(changeset, :nickname, "Anomynous Member")
    end
  end

  ## Application related.

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

  def from_domain(%User{} = user) do
    %__MODULE__{
      id: user.id,
      username: user.username,
      nickname: user.nickname,
      status: user.status |> User.Status.value(),
      gender: user.gender |> User.Gender.value(),
      gender_visible: not (user.gender |> User.Gender.secret?()),
      join_at: user.join_at,
      info: user.info
    }
  end

  def to_domain(%__MODULE__{} = dao) do
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
