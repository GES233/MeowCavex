defmodule Service.User do
  @moduledoc """
  关于用户的服务。
  """
end

defmodule Service.User.Register do
  @moduledoc """
  注册服务。
  """

  alias Domain.User
  alias Domain.User.{Gender, Status}
  alias Domain.User.Authentication, as: UserAuth

  @spec create_auth(maybe_improper_list() | map()) :: Domain.User.Authentication.t()
  def create_auth(fields), do: create_auth(fields[:nickname], fields[:email], fields[:password])

  @spec create_auth(charlist() | nil, String.t(), String.t()) ::
          Domain.User.Authentication.t()
  def create_auth(nickname, email, password) do
    %UserAuth{id: nil, nickname: nickname, email: email, password: password}
  end

  @spec create_blank_user(Domain.User.Authentication.t()) :: Domain.User.t()
  def create_blank_user(%UserAuth{nickname: nickname} = _userauth, timezone \\ "Etc/UTC") do
    # 时区信息应该来自 DTO 。

    current = DateTime.utc_now()

    %User{
      id: nil,
      username: nil,
      nickname: nickname,
      gender: Gender.create(),
      status: Status.create(),
      info: "",
      timezone: timezone,
      join_at: current
    }
  end

  # TODO: Conn with repo.
end
