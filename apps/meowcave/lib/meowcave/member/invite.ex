defmodule MeowCave.Member.InviteRepo do
  use Ecto.Schema
  # import Ecto.Changeset
  alias Ecto.Enum
  alias Member.{User, Invite, InviteCode}
  alias MeowCave.Member.{UserRepo, InviteRepo}

  schema "invite" do
    field :code, :string
    field :status, Enum, values: [:normal]
    field :create_at, :utc_datetime
    field :expire, :time
    # 这块需要讨论下
    belongs_to :host, UserRepo, foreign_key: :host_id
    belongs_to :guest, UserRepo, foreign_key: :guest_id

    # timestamps(insert_at: false, updated_at: false)
  end

  ## 应用相关

  def from_code(%InviteCode{} = code),
    do: %{
      struct(InviteRepo, Map.from_struct(code))
      | status: InviteCode.Status.value(code.status)
    }

  def to_code(%__MODULE__{} = dao),
    do: %{
      struct(InviteCode, Map.from_struct(dao))
      | status: %InviteCode.Status{value: dao.status}
    }

  def to_relationship(%__MODULE__{} = dao) do
    # 如果领域模型改成用户也好操作。
    code_activate = case guest = guest_or_nil(dao) do
      %User{} ->
        %User{join_at: join_at} = guest

        join_at
      nil -> nil
    end
    %{
      struct(Invite, Map.from_struct(dao))
      | invite_at: code_activate
    }
  end

  # 用于查用对应用户的工具函数
  def host_or_nil(%__MODULE__{}), do: %User{}
  def guest_or_nil(%__MODULE__{}), do: %User{}
end
