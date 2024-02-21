defmodule Account do
  @moduledoc """
  关于账号的相关。
  """
end

defmodule Account.TokenPayload do
  @moduledoc """
  令牌内容。
  """

  @type t :: %__MODULE__{
          token_id: charlist(),
          user_id: Member.User.id_type(),
          context: map(),
          scope: Account.TokenScope.scope_type(),
          type: Account.TokenType.token_type()
        }
  defstruct [:token_id, :user_id, :context, :scope, :type]
end

defmodule Account.TokenScope do
  @type scope_type :: atom()
end

defmodule Account.TokenType do
  @type token_type :: :session | :token | :refresh_token
end

defmodule Account.TokenRepo do
  alias Account.TokenPayload
  alias Member.User

  @callback generate_token(User.t()) :: {:ok, TokenPayload.t()} | {:error, any()}

  @callback search_token(User.t()) :: {:ok, [TokenPayload.t()] | []} | {:error, any()}

  @callback verify_token(TokenPayload.t()) ::
              {:ok, User.t()} | {:not_found, nil} | {:error, any()}

  @callback deactivate_token(TokenPayload.t()) :: :ok | nil
end

defmodule Account.Usecase.SessionValidation do
end
