defmodule Account do
  @moduledoc """
  关于账号。
  """
end

defmodule Account.TokenPayload do
  @type t :: %__MODULE__{
    token_id: charlist(),
    user_id: Member.User.id_type(),
    scope: atom(),
    type: atom(),
  }
  defstruct [:token_id, :user_id, :scope, :type]
end

defmodule Account.TokenRepo do

  alias Account.TokenPayload
  alias Member.User

  @callback token_to_user(TokenPayload.t()) :: User.t()
end

defmodule Account.Usecase.SessionValidation do
end
