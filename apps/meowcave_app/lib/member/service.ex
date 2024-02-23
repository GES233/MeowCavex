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
        %Locale{timezone: _timezone, lang: _lang} = _locale,
        current \\ DateTime.utc_now(:second)
      ) do
    # 时区信息应该来自 DTO 。

    %User{
      id: nil,
      username: nil,
      nickname: nickname,
      gender: Gender.create(),
      status: Status.create(),
      info: "",
      # DateTime.shift_zone!(current, timezone)
      join_at: current
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

defmodule Member.Service.UpdateStatus do
  alias Member.User.Status
  alias Member.Service.UpdateStatus

  @spec update_status(old_status :: %Status{}, new_status :: %Status{} | atom()) :: %Status{}
  def update_status(%Status{} = _old_status, %Status{} = new_status) do
    new_status
  end

  def update_status(%Status{} = old_status, new_status) when is_atom(new_status) do
    if new_status not in Status.get_opt_list() do
      raise UpdateStatus.StatusOperationFailed, new_status
    end
    new_status_from_service = apply(Status, new_status, [old_status])

    cond do
      new_status_from_service == Status.operate_when_not_match(new_status) ->
        raise UpdateStatus.StatusInvalid, new_status

      true -> new_status_from_service
    end
  end

  defmodule StatusOperationFailed do
    defexception [:message]

    def exception(wrong_operation) do
      %StatusOperationFailed{
        message: "couldn't update status because of the wrong status operator #{wrong_operation}"
      }
    end
  end

  defmodule StatusInvalid do
    defexception [:message]

    def exception(wrong_status) do
      %StatusInvalid{
        message: "couldn't update status because of the wrong status format #{wrong_status}"
      }
    end
  end
end

defmodule Member.Service.UpdateGender do
  alias Member.User.Gender

  def update_gender(%Gender{}, %Gender{} = new_gender) do
    if Gender.valid?(new_gender) do
      new_gender
    else
      raise Gender.GenderTooDiverseException, new_gender.value
    end
  end

  def update_gender(%Gender{} = old_gender, new_gender_value) when is_atom(new_gender_value) do
    case new_gender_value in Gender.get_valid_values() do
      true -> %{old_gender | value: new_gender_value}
      false -> raise Gender.GenderTooDiverseException, new_gender_value
    end
  end

  def hide_gender(), do: nil
  def expose_gender(), do: nil
end
