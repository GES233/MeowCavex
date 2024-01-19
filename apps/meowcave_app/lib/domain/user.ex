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
  @doc false
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
  TODO: Add.
  """

  @type value :: atom()
  @valid_values [:male, :female, :non_bisexual, :blank]
  @type t :: %__MODULE__{value: value(), hidden: boolean()}
  defstruct value: :blank, hidden: false

  ## Inspect

  @spec value(Domain.User.Gender.t()) :: atom()
  def value(gender) do
    %__MODULE__{value: value} = gender

    value
  end

  @spec valid?(Domain.User.Gender.t()) :: boolean()
  def valid?(gender), do: value(gender) in get_valid_values()

  @spec under(Domain.User.Gender.t(), atom() | list()) :: boolean()
  def under(gender, state) when is_atom(state) do
    state in get_valid_values() and value(gender) == state
  end

  def under(gender, state) when is_list(state) do
    value(gender) in state
  end

  def under(_gender, _state), do: nil
  # TODO: raise exception: invalid.

  @spec hasgender?(any()) :: boolean()
  def hasgender?(gender), do: not under(gender, :blank)

  @spec bisexual?(Domain.User.Gender.t()) :: boolean()
  def bisexual?(gender), do: under(gender, [:male, :female]) and not secret?(gender)

  @spec secret?(Domain.User.Gender.t()) :: boolean()
  def secret?(gender) do
    %{hidden: hide?} = gender

    hide?
  end

  @spec get(Domain.User.Gender.t()) :: atom()
  def get(gender) do
    case secret?(gender) do
      true -> :blank
      false -> value(gender)
    end
  end

  ## Operate

  @spec create() :: Domain.User.Gender.t()
  def create(), do: %__MODULE__{}

  @spec hide(Domain.User.Gender.t()) :: Domain.User.Gender.t()
  def hide(gender), do: %__MODULE__{gender | hidden: true}

  @spec expose(Domain.User.Gender.t()) :: Domain.User.Gender.t()
  def expose(gender), do: %__MODULE__{gender | hidden: false}

  @doc """
  当性别表现为 `blank` 时返回性别。
  """
  @spec give(Domain.User.Gender.t(), atom()) :: Domain.User.Gender.t()
  def give(gender, new_gender) do
    if not hasgender?(gender) do
      update(gender, new_gender)
    else
      gender
    end
  end

  @spec update(Domain.User.Gender.t(), atom()) :: Domain.User.Gender.t()
  def update(gender, new_gender) do
    cond do
      new_gender in get_valid_values() -> %__MODULE__{gender | value: new_gender}
      true -> gender
    end
  end

  defp get_valid_values, do: @valid_values
end
