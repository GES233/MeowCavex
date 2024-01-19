defmodule Domain.User do
  @moduledoc """
  领域模型`用户`是负责与应用内其他主体互动的主要对象。

  下面简单的介绍用户的各键：

  * `id` 用户的 ID ，主要作为标识，并不对展示界面开放
  * `username` 唯一的用户名，仅允许 ASCII 字符，主要用作在应用层的标识（可以参考推特）
  * `nickname` 用户的昵称，可以由用户自主选择
  * `gender` 用户的性别（可由用户隐藏），目前选择二元性别分类（M/F），暂不考虑 LGBTQ+ 以及复杂的多元性别机制
  * `status` 用户的状态，详见 `Domain.User.Status`
  * `timezone` 用户所在地的市区，主要用于展示层时间的变化以及用户的行为的时间的记录
  * `info` 用户所填写的信息
  * `join_at` 用户加入的时间，默认选择 `DateTime`
  """

  alias Domain.User.{Gender, Status}

  @type id_type :: integer()

  @type t :: %__MODULE__{
          id: id_type(),
          username: charlist() | nil,
          nickname: String.t(),
          gender: Gender.t(),
          status: Status.t(),
          # Use value when DTO.
          timezone: charlist(),
          info: String.t(),
          join_at: DateTime.t()
        }
  defstruct [
    :id,
    :username,
    :nickname,
    :gender,
    :status,
    :timezone,
    :info,
    :join_at
  ]

  @spec update(Domain.User.t(), atom(), any()) :: Domain.User.t()
  @doc """
  更新用户的数据。
  """
  def update(user, field, content) do
    {status, new_user, _info} = do_update(user, field, content)

    case status do
      :ok -> new_user
      _ -> user
    end
  end

  defp do_update(user, field, content) when is_map(content) do
    # Struct belongs to map.
    # When Status/Gender
    case field do
      :gender -> {:ok, Map.replace(user, :gender, content), nil}
      :status -> {:ok, Map.replace(user, :status, content), nil}
      _ -> {:error, user, :field_invalid}
    end
  end

  defp do_update(user, field, content) do
    cond do
      field in [:nickname, :username, :info, :timezone] ->
        {:ok, Map.replace(user, field, content), nil}

      field == :gender ->
        {:ok, Map.replace(user, :gender, Gender.give(user.gender, content)), nil}

      true ->
        {:error, user, :content_invalid}
    end
  end

  @spec remove_info(Domain.User.t(), atom()) :: Domain.User.t()
  @doc """
  移除用户的信息。
  """
  def remove_info(user, field) do
    {status, new_user, _info} = do_remove_info(user, field)

    case status do
      :ok -> new_user
      _ -> user
    end
  end

  defp do_remove_info(user, field) do
    case field do
      :gender -> do_update(user, :gender, Gender.hide(user.gender))
      # similar as Register
      :nickname -> do_update(user, :nickname, "")
      :info -> do_update(user, :info, "")
      :timezone -> do_update(user, :timezone, "")
      # [:id, :username, :status, :join_at] -> user
      _ -> {:error, user, :field_invalid}
    end
  end
end

defmodule Domain.User.Status do
  use Domain.Status, [:normal, :deleted, :freeze, :blocked, newbie: :default]

  ## Inspect status

  @spec normal?(Domain.User.Status.t()) :: boolean() | nil
  def normal?(status), do: under(status, :normal)

  @spec blocked?(Domain.User.Status.t()) :: boolean() | nil
  def blocked?(status), do: under(status, :blocked)

  @spec visible?(Domain.User.Status.t()) :: boolean() | nil
  def visible?(status), do: under(status, [:normal, :freeze, :blocked])

  @spec interactive?(Domain.User.Status.t()) :: boolean() | nil
  def interactive?(status), do: under(status, [:normal, :freeze])

  ## Operate

  @spec activate(Domain.User.Status.t()) :: Domain.User.Status.t()
  def activate(status) do
    case value(status) do
      :newbie -> %__MODULE__{value: :normal}
      :freeze -> %__MODULE__{value: :normal}
      _ -> operate_when_not_match(status)
    end
  end

  @spec delete(Domain.User.Status.t()) :: Domain.User.Status.t()
  def delete(status) do
    case value(status) do
      :deleted -> operate_when_not_match(status)
      _ -> %__MODULE__{value: :deleted}
    end
  end

  @spec freeze(Domain.User.Status.t()) :: Domain.User.Status.t()
  def freeze(status) do
    case value(status) do
      :normal -> %__MODULE__{value: :freeze}
      _ -> operate_when_not_match(status)
    end
  end

  @spec block(any()) :: Domain.User.Status.t()
  def block(status) do
    case status do
      :deleted -> operate_when_not_match(status)
      _ -> %__MODULE__{value: :blocked}
    end
  end
end

defmodule Domain.User.Gender do
  @moduledoc """
  性别属于用户的属性之一，其包含两个属性：

  * `value` 性别本身（原子值，目前包括 `:male`、`:female`、`:non_bisexual`、`:blank`）
  * `hidden` 是否不显示性别，布尔值
  """

  @type value :: atom()
  @valid_values [:male, :female, :non_bisexual, :blank]
  @type t :: %__MODULE__{value: value(), hidden: boolean()}
  defstruct value: :blank, hidden: false

  ## Inspect

  @spec value(Domain.User.Gender.t()) :: atom()
  @doc """
  返回当前的性别。
  """
  def value(%__MODULE__{value: value} = _gender) do
    value
  end

  @spec valid?(Domain.User.Gender.t()) :: boolean()
  @doc """
  返回当前的性别是否合法。
  """
  def valid?(gender), do: value(gender) in get_valid_values()

  @spec under(Domain.User.Gender.t(), atom() | list()) :: boolean()
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

  @spec bisexual?(Domain.User.Gender.t()) :: boolean()
  @doc """
  当前的性别是否在二元性别体系内？
  """
  def bisexual?(gender), do: under(gender, [:male, :female]) and not secret?(gender)

  @spec secret?(Domain.User.Gender.t()) :: boolean()
  @doc """
  当前的性别是否是私密的？
  """
  def secret?(gender) do
    %{hidden: hide?} = gender

    hide?
  end

  @spec get(Domain.User.Gender.t()) :: atom()
  @doc """
  应用层面的返回性别（和 `Domain.User.Gender.value/1` 的区别是会被隐藏）
  """
  def get(gender) do
    case secret?(gender) do
      true -> :blank
      false -> value(gender)
    end
  end

  ## Operate

  @spec create() :: Domain.User.Gender.t()
  @doc """
  创建空白的性别
  """
  def create(), do: %__MODULE__{}

  @spec hide(Domain.User.Gender.t()) :: Domain.User.Gender.t()
  @doc """
  隐藏性别
  """
  def hide(gender), do: %__MODULE__{gender | hidden: true}

  @spec expose(Domain.User.Gender.t()) :: Domain.User.Gender.t()
  @doc """
  暴露性别
  """
  def expose(gender), do: %__MODULE__{gender | hidden: false}

  @spec give(Domain.User.Gender.t(), atom()) :: Domain.User.Gender.t()
  @doc """
  当性别为 `blank` 时给予性别。
  """
  def give(gender, new_gender) do
    if not hasgender?(gender) do
      update(gender, new_gender)
    else
      gender
    end
  end

  @spec update(Domain.User.Gender.t(), atom()) :: Domain.User.Gender.t()
  @doc """
  将性别更新到某值（更新成功的前提是新的性别是合法的）
  """
  def update(gender, new_gender) do
    gender_with_status = do_update(gender, new_gender)

    case gender_with_status do
      {:ok, gender} -> gender
      {:error, gender, _invalid_gender} -> gender
    end
  end

  defp do_update(gender, new_gender) do
    cond do
      new_gender in get_valid_values() -> {:ok, %__MODULE__{gender | value: new_gender}}
      true -> {:error, gender, new_gender}
    end
  end

  defp get_valid_values, do: @valid_values
end

defmodule Domain.User.Authentication do
  # authentication fields

  @type t :: %__MODULE__{
          id: Domain.User.id_type(),
          nickname: String.t(),
          email: String.t(),
          password: String.t() | charlist()
        }
  defstruct [:id, :nickname, :email, :password]
end

defmodule Domain.User.Repo do
  @callback create(Domain.User.t(), Domain.User.Authentication.t()) ::
            {:ok, Domain.User.t()} | {:error, any()}
end
