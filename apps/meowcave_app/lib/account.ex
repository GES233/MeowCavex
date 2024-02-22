defmodule Account do
  @moduledoc """
  关于账号的相关。
  """
end

defmodule Account.TokenPayload do
  @moduledoc """
  令牌内容。
  """

  @type token_id :: charlist()

  @type t :: %__MODULE__{
          token_id: token_id(),
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

  @expire_time %{
    session: 30,
    token: 7,
    refresh_token: 60
  }

  def get_expire_time(create_time, token_type),
    do: DateTime.add(create_time, @expire_time[token_type], :day)
end

defmodule Account.TokenRepo do
  alias Account.TokenPayload
  alias Member.User

  @callback create_token(
              user :: User.t(),
              scope :: Account.TokenScope.scope_type(),
              type :: Account.TokenType.token_type()
            ) :: {:ok, TokenPayload.t()} | {:error, any()}

  @callback search_token(user :: User.t()) ::
              {:ok, [TokenPayload.t()]} | {:not_found, nil} | {:error, any()}

  @callback verify_token(id :: TokenPayload.token_id()) ::
              {:ok, TokenPayload.t()} | {:not_found, nil} | {:error, any()}

  @callback verify_token(
              id :: TokenPayload.token_id(),
              scope :: Account.TokenScope.scope_type(),
              type :: Account.TokenType.token_type()
            ) ::
              {:ok, TokenPayload.t()} | {:not_found, nil} | {:error, any()}

  @callback deactivate_token(TokenPayload.token_id()) :: :ok | :not_found
end

defmodule Account.SessionValidate do
  # @session_type :session

  def call(), do: nil
end
