defmodule Member.Usecase do
  # TODO: integrate all usecases.
end

defmodule Member.Usecase.Register do
  @moduledoc """
  关于注册的用例。

  ## Example

      Member.Usecase.Register.call(..., repo: MeowCave.Member)

  可能被抛出的错误：

  * `Member.Service.EmailCollide` 邮件已经有用户注册了
  """
  alias Member.User
  alias Member.Service.Register

  @default_repo Application.compile_env(:meowcave_app, [:default_ports, :user_repo], nil)
  @default_hash Application.compile_env(:meowcave_app, [:default_ports, :password_hash], nil)

  defp parse_opts(opts) do
    {repo, opts} = Keyword.pop(opts, :repo, @default_repo)
    {pass_hash, _opts} = Keyword.pop(opts, :pass_hash, @default_hash)

    %{repo: repo, pass_hash: pass_hash}
  end

  @spec call(String.t(), String.t(), String.t(), charlist(), charlist(), keyword(module())) ::
          User.t()
  def call(nickname, email, password, lang \\ "zh-Hans", timezone \\ "Etc/UTC", opts \\ []) do
    %{repo: repo, pass_hash: hashlib} = parse_opts(opts)

    locale_field = Register.create_locale(lang, timezone)

    auth_field = %{
      Register.create_auth(nickname, email, password)
      | hashed_password: hashlib.generate_hash(password)
    }

    {status, user_or_changeset} = repo.create(auth_field, locale_field)

    case status do
      :ok ->
        user_or_changeset

      :error ->
        error_handler(auth_field, locale_field, user_or_changeset)
    end
  end

  @doc """
  返回 Ecto.Changeset 中出错的列。
  """
  def get_error_field(changeset) do
    get_fields = fn l ->
      {field, _} = l

      field
    end

    changeset.errors |> Enum.map(get_fields)
  end

  defp error_handler(
         %Member.User.Authentication{email: conflict_email},
         %Member.User.Locale{},
         changeset
       ) do
    case get_error_field(changeset) do
      [:email] ->
        raise Register.EmailCollide, "#{:email} `#{conflict_email}` has already been taken"

      [:email, _] ->
        raise Register.EmailCollide, "#{:email} `#{conflict_email}` has already been taken"

      # Reserved
      _ ->
        raise unknown_error: changeset
    end
  end
end

defmodule Member.Usecase.Modify do
  @moduledoc """
  修改用户的信息。
  """
  alias Member.User

  @default_repo Application.compile_env(:meowcave_app, [:default_ports, :user_repo], nil)

  defp parse_opts(opts) do
    {repo, opts} = Keyword.pop(opts, :repo, @default_repo)
    {locale, opts} = Keyword.pop(opts, :locale, false)
    {auth, _opts} = Keyword.pop(opts, :auth, false)

    %{repo: repo, locale: locale, auth: auth}
  end

  @doc """
  更新特定用户的信息的服务。

  选项中的 `:locale` 与 `:auth` 为决定返回格式的布尔值。

  - `{false, flase}` => 对 `%User{}` 领域模型的内容进行更新
  - `{true,  false}` => 对特定用户的属地信息进行更新
  - `{false,  true}` => 对特定用户的认证信息进行更新
  """
  @spec update_service(User.t(), atom(), any(), keyword()) ::
          {:ok, Member.User.t() | Member.User.Authentication.t() | Member.User.Locale.t()}
          | {:error, any()}
  def update_service(%User{} = user, field, new_value, opts \\ []) do
    %{repo: repo, auth: auth, locale: locale} = parse_opts(opts)

    do_update_service(user, %{field => new_value}, repo, locale, auth)
  end

  defp do_update_service(%User{} = user, %{} = values, repo, locale, auth) do
    repo.update_user_info(user, values, locale, auth)
  end

  @doc """
  批量更改。

  用于用户主页的修改。
  """
  @spec multiple_update_service(User.t(), map(), keyword()) ::
          {:ok, Member.User.t() | Member.User.Authentication.t() | Member.User.Locale.t()}
          | {:error, any()}
  def multiple_update_service(%User{} = user, values, opts \\ []) do
    %{repo: repo, auth: auth, locale: locale} = parse_opts(opts)

    do_update_service(user, values, repo, locale, auth)
  end

  @doc """
  返回 Ecto.Changeset 中出错的列。
  """
  def get_error_field(changeset) do
    get_fields = fn l ->
      {field, _} = l

      field
    end

    changeset.errors |> Enum.map(get_fields)
  end
end

defmodule Member.Usecase.ModifyUser do
  @moduledoc """
  修改用户信息的相关用例。

  包括昵称、用户名以及信息。
  """

  alias Member.User
  alias Member.Usecase.ModifyUser.UsernameCollide
  alias Member.Usecase.Modify

  @spec nickname(User.t(), String.t(), keyword()) :: User.t()
  def nickname(user, new_nickname, opts \\ []) do
    case Modify.update_service(user, :nickname, new_nickname, Keyword.take(opts, [:repo])) do
      {:ok, user} -> user
      {:error, changeset} -> [unknown_err: changeset] |> IO.inspect()
    end
  end

  # TODO: Wrap it.
  @spec username(User.t(), String.t(), keyword()) :: User.t()
  def username(user, new_username, opts \\ []) do
    # 添加查找设置（允许修改 username / 修改时限）
    # 添加计时的业务逻辑
    case Modify.update_service(user, :username, new_username, Keyword.take(opts, [:repo])) do
      {:ok, user} ->
        user

      {:error, changeset} ->
        case Modify.get_error_field(changeset) do
          [:username] -> raise UsernameCollide
          _ -> [unknown_err: changeset] |> IO.inspect()
        end
    end
  end

  @spec info(User.t(), String.t(), keyword()) :: User.t()
  def info(user, new_info, opts \\ []) do
    case Modify.update_service(user, :info, new_info, Keyword.take(opts, [:repo])) do
      {:ok, user} -> user
      {:error, changeset} -> [unknown_err: changeset] |> IO.inspect()
    end
  end

  defmodule UsernameCollide do
    defexception [:message]
  end

  defmodule ModifyUsernameFailure do
    # 按照用户注册时间开始算吧，如果真的从修改用户名记
    # 时间戳的话得累死；或者是干脆设成不能修改的。
    # TODO
  end

  defmodule InfoNotAllowed do
    # TODO: 接上个关键词或 NLP 实现过滤
  end
end

defmodule Member.Usecase.ModifyLocaleInfo do
  @moduledoc """
  和 `Member.Usecase.ModifyUser` 在应用层面不同，但是本质上是一样的。
  """

  alias Member.User
  alias Member.Usecase.Modify

  @spec timezone(User.t(), String.t() | charlist(), keyword()) :: User.Locale.t()
  def timezone(%User{} = user, new_timezone, opts \\ []) do
    # TODO: 添加时区数据库的检查
    case Modify.update_service(
           user,
           :timezone,
           new_timezone,
           [locale: true] ++ Keyword.take(opts, [:repo])
         ) do
      {:ok, user} -> user
      {:error, changeset} -> [unknown_err: changeset] |> IO.inspect()
    end
  end

  @spec language(User.t(), String.t() | charlist(), keyword()) :: User.Locale.t()
  def language(%User{} = user, new_language, opts \\ []) do
    case Modify.update_service(
           user,
           :lang,
           new_language,
           [locale: true] ++ Keyword.take(opts, [:repo])
         ) do
      {:ok, user} -> user
      {:error, changeset} -> [unknown_err: changeset] |> IO.inspect()
    end
  end
end

defmodule Member.Usecase.ModifySentitiveInfo do
  @moduledoc """
  和 `Member.Usecase.Modify` 不同的是这些的信息是相对敏感的。
  """
  alias Member.User
  alias Member.Usecase.Modify

  @default_repo Application.compile_env(:meowcave_app, [:default_ports, :user_repo], nil)
  @default_hash Application.compile_env(:meowcave_app, [:default_ports, :password_hash], nil)

  defp parse_opts(opts) do
    {repo, opts} = Keyword.pop(opts, :repo, @default_repo)
    {pass_hash, _opts} = Keyword.pop(opts, :pass_hash, @default_hash)

    %{repo: repo, pass_hash: pass_hash}
  end

  ## 密码

  defp do_update_password(%User{} = user, new_password, opts) do
    %{repo: repo, pass_hash: hashlib} = parse_opts(opts)

    Modify.update_service(user, :password, hashlib.generate_hash(new_password),
      repo: repo,
      auth: true
    )
  end

  # 通过命令、邮件或邀请树
  def update_password_in_shell(%User{} = user, new_password, opts \\ []),
    do: do_update_password(user, new_password, opts)

  ## 邮件

  # 通过命令

  # 通过邀请树
end

defmodule Member.Usecase.UpdateStatus do
  @moduledoc """
  更改用户的状态，因为其和信息不同的性质所以单独列出。
  """

  alias Member.User
  alias Member.Usecase.Modify
  alias Member.Service.UpdateStatus, as: ServiceUpdate

  @status :status

  @doc """
  执行更新用户状态的操作。

  其中 `new_status` 是 `Status` 中的合法操作。
  """
  def update_status(%User{} = user, new_status, opts \\ []) do
    new_status_from_domain = ServiceUpdate.update_status(user.status, new_status)

    case Modify.update_service(
           user,
           @status,
           new_status_from_domain,
           Keyword.take(opts, [:repo])
         ) do
      {:ok, user} -> user
      {:error, changeset} -> [unknown_err: changeset]
    end
  end
end

defmodule Member.Usecase.UpdateGender do
  alias Member.User
  alias Member.User.Gender
  alias Member.Service.UpdateGender
  alias Member.Usecase.Modify

  @default_repo Application.compile_env(:meowcave_app, [:default_ports, :user_repo], nil)

  defp parse_opts(opts) do
    {repo, _opts} = Keyword.pop(opts, :repo, @default_repo)

    %{repo: repo}
  end

  defp handle_gender_changset_err(changeset) do
    case Modify.get_error_field(changeset) do
      [:gender] -> nil
      [:gender_visible] -> nil
      [:gender, :gender_visible] -> nil
      _ -> [unknown_error: changeset]
    end
  end

  defp do_update_gender(%User{} = user, %Gender{} = new_gender, opts) do
    %{repo: repo} = parse_opts(opts)

    case repo.update_user_gender(user, new_gender) do
      {:ok, user} ->
        user

      {:error, changeset} ->
        handle_gender_changset_err(changeset)
    end
  end

  def update_gender(user, new_gender, opts \\ []) do
    do_update_gender(user, UpdateGender.update_gender(user.gender, new_gender), opts)
  end

  def hide_gender(user, opts \\ []),
    do: do_update_gender(user, UpdateGender.hide_gender(user.gender), opts)

  def expose_gender(user, opts \\ []),
    do: do_update_gender(user, UpdateGender.expose_gender(user.gender), opts)
end

defmodule Member.Usecase.InviteUser do
  @doc """
  邀请用户。
  """

  def invite_user_without_code(), do: nil
  def invite_user_with_code(), do: nil
  def invite_user_with_user(), do: nil
end
