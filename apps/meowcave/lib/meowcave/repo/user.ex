defmodule MeowCave.Repo.Member do
  @moduledoc """
  俺也不知道咋写。
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias Ecto.Enum

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
end
