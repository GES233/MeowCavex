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
    field :gender_visible, :boolean
    field :info, :string
    field :join_at, :utc_datetime
    # from Member.User.Authentication
    field :email, :string
    field :password, :binary
    # from Member.User.Locale
    field :timezone, :string
    field :lang, :string

    timestamps()
  end

  ## Changeset

  def changeset(user, _attrs) do
    user
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
      status: User.Status.create() |> User.Status.value() |> Atom.to_string(),
      gender: User.Gender.create() |> User.Gender.value() |> Atom.to_string(),
      gender_visible: not (User.Gender.create() |> User.Gender.secret?()),
      join_at: DateTime.utc_now(),
      email: auth_field.email,
      password: auth_field.hashed_password,
      timezone: locale.timezone,
      lang: locale.lang,
    }
  end

  def to_domain(%__MODULE__{} = dao) do
    %User{
      id: dao.id,
      username: dao.username,
      nickname: dao.nickname,
      gender: %User.Gender{
        value: dao.gender |> String.to_atom,
        hidden: not(dao.gender_visible)
      },
      status: %User.Status{
        value: dao.status |> String.to_atom
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
