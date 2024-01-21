defmodule Member.User do
  @moduledoc """
  领域模型 `Member.User` 是负责与应用内其他主体互动的主要对象。

  下面简单的介绍用户的各键：

  * `id` 用户的 ID ，主要作为标识，并不对展示界面开放
  * `username` 唯一的用户名，仅允许 ASCII 字符，主要用作在应用层的标识（可以参考推特）
  * `nickname` 用户的昵称，可以由用户自主选择
  * `gender` 用户的性别（可由用户隐藏），目前选择二元性别分类（M/F），暂不考虑 LGBTQ+ 以及复杂的多元性别机制
  * `status` 用户的状态，详见 `Member.User.Status`
  * `info` 用户所填写的信息
  * `join_at` 用户加入的时间，默认选择 `DateTime`
  """

  import Status
  alias Member.User.ContentInvalidError
  alias Member.User.{Gender}
  alias Member.User.FieldInvalidError

  @type id_type :: integer()

  @type t :: %__MODULE__{
          id: id_type(),
          username: charlist() | nil,
          nickname: String.t(),
          gender: Gender.t(),
          status: Status.t(),
          # Use value when DTO.
          # timezone: charlist(),
          info: String.t(),
          join_at: DateTime.t()
        }
  defstruct [
    :id,
    :username,
    :nickname,
    :gender,
    :status,
    # :timezone,
    :info,
    :join_at
  ]

  @spec update!(Member.User.t(), atom(), any()) :: Member.User.t()
  @doc """
  更新用户的数据。
  """
  def update!(user, field, content) do
    {status, new_user_or_info} = update(user, field, content)

    case status do
      :ok ->
        new_user_or_info

      _ ->
        case new_user_or_info do
          :field_invalid ->
            raise FieldInvalidError, field

          :content_invalid ->
            raise ContentInvalidError, content: content, field: field

          _ ->
            raise "Reserved error with unknown error info #{inspect(new_user_or_info)}"
            # Reserved
        end
    end
  end

  def update(user, field, content) when is_map(content) do
    # Struct belongs to map.
    # When Status/Gender
    case field do
      :gender -> {:ok, Map.replace(user, :gender, content)}
      :status -> {:ok, Map.replace(user, :status, content)}
      _ -> {:error, :field_invalid}
    end
  end

  def update(user, field, content) do
    gender_opt = fn user, new_content ->
      {status, gender_or_err} = Gender.update(user.gender, new_content)

      case status do
        :ok -> {:ok, Map.replace(user, :gender, gender_or_err)}
        :error -> {:error, :content_invalid}
      end
    end

    status_opt = fn user, status_transform ->
      cond do
        status_transform in Member.User.Status.get_opt_list() ->
          {:ok,
           Map.replace(user, :status, apply(Member.User.Status, status_transform, [user.status]))}

        true ->
          {:error, :content_invalid}
      end
    end

    cond do
      field in [:nickname, :username, :info] ->
        {:ok, Map.replace(user, field, content)}

      field == :gender ->
        gender_opt.(user, content)

      field == :status ->
        status_opt.(user, content)

      true ->
        {:error, :field_invalid}
    end
  end

  @spec remove_info!(Member.User.t(), atom()) :: Member.User.t()
  @doc """
  移除用户的信息。
  """
  def remove_info!(user, field) do
    {status, new_user_or_info} = remove_info(user, field)

    case status do
      :ok ->
        new_user_or_info

      _ ->
        case new_user_or_info do
          :field_invalid ->
            raise FieldInvalidError, field

          _ ->
            raise "Reserved error with unknown error info #{inspect(new_user_or_info)}"
            # Reserved
        end
    end
  end

  def remove_info(user, field) do
    case field do
      :gender -> update(user, :gender, Gender.hide(user.gender))
      # similar as Register
      :nickname -> update(user, :nickname, "")
      :info -> update(user, :info, "")
      # [:id, :username, :status, :join_at] -> user
      _ -> {:error, :field_invalid}
    end
  end

  defmodule FieldInvalidError do
    defexception [:message]

    @impl true
    def exception(invalid_field) do
      msg =
        "The field you attempt to contrive or write(#{inspect(invalid_field)}) is invalid here."

      %FieldInvalidError{message: msg}
    end
  end

  defmodule ContentInvalidError do
    defexception [:message]

    @impl true
    def exception(invalid_content) do
      msg =
        "The content(#{inspect(invalid_content[:content])}) in #{inspect(invalid_content[:field])} is invalid."

      %ContentInvalidError{message: msg}
    end
  end
end

defmodule Member.User.Status do
  use Status, [:normal, :deleted, :freeze, :blocked, newbie: :default]

  ## Inspect status

  @spec normal?(Member.User.Status.t()) :: boolean() | nil
  def normal?(status), do: under(status, :normal)

  @spec blocked?(Member.User.Status.t()) :: boolean() | nil
  def blocked?(status), do: under(status, :blocked)

  @spec visible?(Member.User.Status.t()) :: boolean() | nil
  def visible?(status), do: under(status, [:normal, :freeze, :blocked])

  @spec interactive?(Member.User.Status.t()) :: boolean() | nil
  def interactive?(status), do: under(status, [:normal, :freeze])

  ## Operate

  @opt_list [:activate, :delete, :freeze, :block]
  def get_opt_list(), do: @opt_list

  @spec activate(Member.User.Status.t()) :: Member.User.Status.t()
  def activate(status) do
    case value(status) do
      :newbie -> %__MODULE__{value: :normal}
      :freeze -> %__MODULE__{value: :normal}
      _ -> operate_when_not_match(status)
    end
  end

  @spec delete(Member.User.Status.t()) :: Member.User.Status.t()
  def delete(status) do
    case value(status) do
      :deleted -> operate_when_not_match(status)
      _ -> %__MODULE__{value: :deleted}
    end
  end

  @spec freeze(Member.User.Status.t()) :: Member.User.Status.t()
  def freeze(status) do
    case value(status) do
      :normal -> %__MODULE__{value: :freeze}
      _ -> operate_when_not_match(status)
    end
  end

  @spec block(any()) :: Member.User.Status.t()
  def block(status) do
    case status do
      :deleted -> operate_when_not_match(status)
      _ -> %__MODULE__{value: :blocked}
    end
  end
end

defmodule Member.User.Gender do
  @moduledoc """
  性别属于用户的属性之一，其包含两个属性：

  * `value` 性别本身（原子值，目前包括 `:male`、`:female`、`:non_bisexual`、`:blank`）
  * `hidden` 是否不显示性别，布尔值
  """
  alias Member.User.Gender.GenderTooDiverseException

  @type value :: atom()
  @valid_values [:male, :female, :non_bisexual, :blank]
  @type t :: %__MODULE__{value: value(), hidden: boolean()}
  defstruct value: :blank, hidden: false

  ## Inspect

  @spec value(Member.User.Gender.t()) :: atom()
  @doc """
  返回当前的性别。
  """
  def value(%__MODULE__{value: value} = _gender) do
    value
  end

  @spec valid?(Member.User.Gender.t()) :: boolean()
  @doc """
  返回当前的性别是否合法。
  """
  def valid?(gender), do: value(gender) in get_valid_values()

  @spec under(Member.User.Gender.t(), atom() | list()) :: boolean()
  @doc """
  当前的性别是否是所输入的状态？
  """
  def under(gender, state) when is_atom(state) do
    state in get_valid_values() and value(gender) == state
  end

  def under(gender, state) when is_list(state) do
    value(gender) in state
  end

  def under(_gender, _state), do: nil
  # TODO: raise exception: invalid.

  @spec hasgender?(any()) :: boolean()
  @doc """
  当前的性别是否为空？（会跳过用户设置的隐藏属性）
  """
  def hasgender?(gender), do: not under(gender, :blank)

  @spec bisexual?(Member.User.Gender.t()) :: boolean()
  @doc """
  当前的性别是否在二元性别体系内？
  """
  def bisexual?(gender), do: under(gender, [:male, :female]) and not secret?(gender)

  @spec secret?(Member.User.Gender.t()) :: boolean()
  @doc """
  当前的性别是否是私密的？
  """
  def secret?(gender) do
    %{hidden: hide?} = gender

    hide?
  end

  @spec get(Member.User.Gender.t()) :: atom()
  @doc """
  应用层面的返回性别（和 `Member.User.Gender.value/1` 的区别是会被隐藏）
  """
  def get(gender) do
    case secret?(gender) do
      true -> :blank
      false -> value(gender)
    end
  end

  ## Operate

  @spec create() :: Member.User.Gender.t()
  @doc """
  创建空白的性别
  """
  def create(), do: %__MODULE__{}

  @spec hide(Member.User.Gender.t()) :: Member.User.Gender.t()
  @doc """
  隐藏性别
  """
  def hide(gender), do: %__MODULE__{gender | hidden: true}

  @spec expose(Member.User.Gender.t()) :: Member.User.Gender.t()
  @doc """
  暴露性别
  """
  def expose(gender), do: %__MODULE__{gender | hidden: false}

  def give!(gender, new_gender) do
    {status, gender_or_err} = give(gender, new_gender)

    case status do
      :ok -> gender_or_err
      :has_gender -> gender_or_err
      :error -> raise GenderTooDiverseException, gender_or_err
    end
  end

  @spec give(Member.User.Gender.t(), atom()) :: Member.User.Gender.t()
  @doc """
  当性别为 `blank` 时给予性别。
  """
  def give(gender, new_gender) do
    if not hasgender?(gender) do
      update(gender, new_gender)
    else
      {:has_gender, gender}
    end
  end

  @spec update!(Member.User.Gender.t(), atom()) :: Member.User.Gender.t()
  @doc """
  将性别更新到某值（更新成功的前提是新的性别是合法的）
  """
  def update!(gender, new_gender) do
    {status, gender_or_error} = update(gender, new_gender)

    case status do
      :ok -> gender_or_error
      :error -> raise GenderTooDiverseException, gender
    end
  end

  @spec update(Member.User.Gender.t(), atom()) :: {:ok, Member.User.Gender.t()} | {:error, any()}
  @doc """
  将性别更新到某值，会返回状态以及结果
  """
  def update(gender, new_gender) do
    cond do
      new_gender in get_valid_values() -> {:ok, %__MODULE__{gender | value: new_gender}}
      true -> {:error, new_gender}
    end
  end

  defp get_valid_values, do: @valid_values

  defmodule GenderTooDiverseException do
    @moduledoc """
    如其名，太过多元的性别（包括但不限于武装直升机）。
    """
    defexception [:message]

    @impl true
    def exception(new_gender) do
      msg =
        "The genders you entered(#{inspect(new_gender)}) are so diverse that sites can't correspond."

      %GenderTooDiverseException{message: msg}
    end
  end
end

defmodule Member.User.Locale do
  @moduledoc """
  关于用户的定位（目前包括语言偏好和市区）。

  其中用户使用的语言可以与业务无关（虽然代码会写英文但是默认是简体中文），
  但是用户的时区可能需要（就如果所谓 IP 属地一样），因此后者会持久化。
  """
  @type t :: %__MODULE__{
          id: Member.User.id_type(),
          lang: charlist(),
          timezone: charlist()
        }
  defstruct [:id, :lang, :timezone]
end

defmodule Member.User.Authentication do
  @moduledoc """
  说白了就两个使用场景：

  * 需要确定你是你的（注册、登录等）
  * 涉及到你对你的确认的（密码重置啥的）
  """

  # authentication fields

  @type t :: %__MODULE__{
          id: Member.User.id_type(),
          nickname: String.t(),
          email: String.t(),
          password: String.t(),
          hashed_password: charlist()
        }
  @enforce_keys [:nickname, :email, :password]
  defstruct [:id, :nickname, :email, :password, :hashed_password]

  def has_id?(%__MODULE__{} = authn), do: authn.id != nil
end

defmodule Member.User.Repo do
  @doc """
  按照给定的领域对象向仓库添加用户。
  """
  @callback create(Member.User.Authentication.t(), Member.User.Locale.t()) ::
              {:ok, Member.User.t()} | {:error, any()}

  @callback update_user_info(Member.User.t(), map(), boolean(), boolean()) ::
              {:ok, Member.User.t() | Member.User.Authentication.t() | Member.User.Locale.t()}
              | {:error, any()}

  @callback get_user_by_id(pos_integer()) :: Member.User.t() | nil
end

defmodule Member.Invite do
  @moduledoc """
  关于成员间的邀请关系，其将在很多场合被使用（
  例如邀请注册、惩罚的连坐、无法使用邮件的情况下的密码验证）。
  """

  @type t :: %__MODULE__{
          user_id: Member.User.id_type()
        }
  defstruct [:user_id]
end
