defmodule MeowCave.Member.UserTokenRepo do
  use Ecto.Schema

  #@hash_algorithm :sha256
  #@rand_size 32

  # 密码重置令牌的过期时间不能太长，否则其他人可能会通过此渠道来登录账号。
  #@session_validity_in_days 60

  schema "user_tokens" do
    field :token, :binary
    # TODO: update with Ecto.Enum
    field :context, :string
    field :scope, :string
    field :sent_to, :string
    belongs_to :users, MeowCave.Member.UserRepo

    timestamps(updated_at: false)
  end

  ## Application related
end

defmodule MeowCave.Member.UserToken.Crypt do
  # @behaviour Account.TokenRepo
end
