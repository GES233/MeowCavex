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
    field :status, Enum, values: Member.User.Status.get_valid_values()
    # [:normal, :deleted, :freeze, :blocked, :newbie]
    field :gender, Enum, values: Member.User.Gender.get_valid_values()
    # [:male, :female, :non_bisexual, :blank]
    field :gender_visible, :boolean, default: false
    field :info, :string
    # field :join_at, :utc_datetime
    # from Member.User.Authentication
    field :email, :string
    field :password, :string, redact: true
    # from Member.User.Locale
    field :timezone, :string
    field :lang, :string

    # timestamps/1 in here from
    # https://hexdocs.pm/ecto/Ecto.Schema.html#timestamps/1
    # 没法从配置改
    timestamps(inserted_at: :join_at, type: :utc_datetime)
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

  defp changeset_update_gender(%__MODULE__{} = user, attrs) do
    cast(user, attrs, [:gender, :gender_visible])
  end

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

  def update_gender_changeset(user, gender_or_visibility) do
    user
    |> changeset_update_gender(gender_or_visibility)
  end

  ## Application related.

  # DTO -> DAO
  def from_domain(%User.Authentication{} = auth_field, %User.Locale{} = locale) do
    %{
      struct(
        MeowCave.Member.UserRepo,
        Map.merge(Map.from_struct(auth_field), Map.from_struct(locale))
      )
      | password: auth_field.hashed_password,
        status: User.Status.create() |> User.Status.value(),
        gender: User.Gender.create() |> User.Gender.value(),
        gender_visible: not (User.Gender.create() |> User.Gender.secret?()),
        join_at: DateTime.utc_now(:second)
    }
  end

  # Domain -> DTO
  def from_domain(%User{} = user) do
    %{
      struct(MeowCave.Member.UserRepo, Map.from_struct(user))
      | status: User.Status.value(user.status),
        gender: User.Gender.value(user.gender),
        gender_visible: not User.Gender.secret?(user.gender)
    }
  end

  def to_domain(%__MODULE__{} = dao, locale \\ false, auth \\ false) do
    case {locale, auth} do
      {false, false} ->
        %{
          struct(Member.User, Map.from_struct(dao))
          | gender: %User.Gender{
              value: dao.gender,
              hidden: not dao.gender_visible
            },
            status: %User.Status{
              value: dao.status
            }
        }

      {true, false} ->
        struct(User.Locale, Map.from_struct(dao))

      {false, true} ->
        %{
          struct(User.Authentication, Map.from_struct(dao))
          | hashed_password: dao.password
        }
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
