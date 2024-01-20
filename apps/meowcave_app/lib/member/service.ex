defmodule Member.Service do
  @moduledoc """
  关于用户的服务。
  """
end

defmodule Member.Service.Password do
  @callback generate_hash(String.t()) :: charlist()
  @callback verify_pswd(String.t(), charlist()) :: boolean()
end

defmodule Member.Service.Register do
  @moduledoc """
  注册服务。
  """

  alias Member.User
  alias Member.User.{Gender, Status, Locale}
  alias Member.User.Authentication, as: MemberAuth

  # DTO2VO

  @spec create_auth(maybe_improper_list() | map()) :: Member.User.Authentication.t()
  def create_auth(fields), do: create_auth(fields[:nickname], fields[:email], fields[:password])

  @spec create_auth(charlist() | nil, String.t(), String.t()) ::
          Member.User.Authentication.t()
  def create_auth(nickname, email, password) do
    %MemberAuth{id: nil, nickname: nickname, email: email, password: password}
  end

  def create_locale(prefer_lang, timezone), do: %Locale{lang: prefer_lang, timezone: timezone}

  # VO2Entity

  @spec create_blank_user(Member.User.Authentication.t(), Member.User.Locale.t()) ::
          Member.User.t()
  def create_blank_user(
        %MemberAuth{nickname: nickname} = _userauth,
        %Locale{timezone: timezone} = _locale
      ) do
    # 时区信息应该来自 DTO 。

    current = DateTime.utc_now()

    %User{
      id: nil,
      username: nil,
      nickname: nickname,
      gender: Gender.create(),
      status: Status.create(),
      info: "",
      join_at: DateTime.shift_zone!(current, timezone)
    }
  end

  # TODO: Conn with repo.

  ## Exceptions

  defmodule EmailCollide do
    defexception [:message]

    @impl true
    def exception(collide_email) do
      msg = "#{inspect(collide_email)}"

      %EmailCollide{message: msg}
    end
  end
end

defmodule Member.Service.UpdateLocale do
  @moduledoc """
  更新用户地区相关。
  """

  alias Member.User.Locale

  @callback get_lang(any()) :: charlist()
  @callback get_timezone(any()) :: charlist()

  def update_lang(%Locale{} = locale, lang), do: %Locale{locale | lang: lang}
  def update_timezone(%Locale{} = locale, timezone), do: %Locale{locale | timezone: timezone}
end
