defmodule Meowcave.Member.InviteRepo do
  use Ecto.Schema
  # import Ecto.Changeset
  alias Ecto.Enum

  schema "invite" do
    field :code, :string
    field :status, Enum, values: [:normal]
    field :create_at, :utc_datetime
    field :expire, :time
    # 这块需要讨论下
    has_many :host, MeowCave.Member.UserRepo
    has_one :guest, MeowCave.Member.UserRepo

    timestamps(insert_at: false, updated_at: false, type: :utc_datetime)
  end

  ## 应用相关

  def from_code(%Member.InviteCode{} = dao),
    do: %__MODULE__{
      code: dao.code,
      create_at: dao.create_at
    }
end
