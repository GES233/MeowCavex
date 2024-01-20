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
  alias Domain.User.{Gender, Status, Locale}
  alias Domain.User.Authentication, as: UserAuth

  # DTO2VO

  @spec create_auth(maybe_improper_list() | map()) :: Domain.User.Authentication.t()
  def create_auth(fields), do: create_auth(fields[:nickname], fields[:email], fields[:password])

  @spec create_auth(charlist() | nil, String.t(), String.t()) ::
          Domain.User.Authentication.t()
  def create_auth(nickname, email, password) do
    %UserAuth{id: nil, nickname: nickname, email: email, password: password}
  end

  def create_locale(), do: %Locale{}

  # VO2Entity

  @spec create_blank_user(Domain.User.Authentication.t(), Domain.User.Locale.t()) :: Domain.User.t()
  def create_blank_user(%UserAuth{nickname: nickname} = _userauth, %Locale{} = _locale) do
    # 时区信息应该来自 DTO 。

    current = DateTime.utc_now()

    %User{
      id: nil,
      username: nil,
      nickname: nickname,
      gender: Gender.create(),
      status: Status.create(),
      info: "",
      join_at: current
    }
  end

  # TODO: Conn with repo.
end

defmodule Service.User.UpdateLocale do
  @moduledoc """
  更新用户地区相关。
  """

  # 话说 Elixir 怎么实现类似于依赖注入的东西啊，难道只能通过 callback 或配置吗？
end
