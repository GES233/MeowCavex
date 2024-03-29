defmodule MeowCave.Member.UserTokenRepo do
  use Ecto.Schema

  # @hash_algorithm :sha256
  # @rand_size 32

  # 密码重置令牌的过期时间不能太长，否则其他人可能会通过此渠道来登录账号。
  # ？？？
  # @session_validity_in_days 60

  schema "user_tokens" do
    field :token, :binary
    field :context, :map
    field :scope, :string
    field :type, Ecto.Enum, values: Account.TokenType.get_type_list()
    field :sent_to, :string
    belongs_to :users, MeowCave.Member.UserRepo

    timestamps(updated_at: false, type: :utc_datetime)
    # field :expired_at, :utc_datetime
  end

  ## Application related
end

defmodule MeowCave.Member.UserToken.Crypt do
  # @behaviour Account.TokenRepo
end
