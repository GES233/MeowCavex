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

  defp parse_deps(opts) do
    {repo, opts} = Keyword.pop(opts, :repo, @default_repo)
    {pass_hash, _opts} = Keyword.pop(opts, :pass_hash, @default_hash)

    %{repo: repo, pass_hash: pass_hash}
  end

  @spec call(String.t(), String.t(), String.t(), charlist(), charlist(), keyword(module())) ::
          User.t()
  def call(nickname, email, password, lang \\ "zh-Hans", timezone \\ "Etc/UTC", opts \\ []) do
    %{repo: repo, pass_hash: hashlib} = parse_deps(opts)

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

  defp error_handler(
         %Member.User.Authentication{email: conflict_email},
         %Member.User.Locale{},
         changeset
       ) do
    get_fields = fn l ->
      {field, _} = l

      field
    end

    case changeset.errors |> Enum.map(get_fields) do
      [:email] ->
        raise Register.EmailCollide, "#{:email} `#{conflict_email}` has already been taken"

      [:email, _] ->
        raise Register.EmailCollide, "#{:email} `#{conflict_email}` has already been taken"

      # Reserved
      _ ->
        nil
    end
  end
end

defmodule Member.Usecase.Modify do
  @moduledoc """
  修改用户的信息。
  """
  alias Member.User

  @default_repo MeowCave.Member

  defp parse_deps(opts) do
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
    %{repo: repo, auth: auth, locale: locale} = parse_deps(opts)

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
    %{repo: repo, auth: auth, locale: locale} = parse_deps(opts)

    do_update_service(user, values, repo, locale, auth)
  end

  def error_handler(_changeset), do: nil
  # TODO: convert changeset to fields.
end

defmodule Member.Usecase.ModifyUser do
  @moduledoc """
  修改用户信息的相关用例。

  包括昵称、用户名以及信息。
  """

  alias Member.Usecase.Modify

  @spec nickname(Member.User.t(), String.t(), keyword()) ::
          {:ok, Member.User.t()} | {:error, any()}
  def nickname(user, new_nickname, opts \\ []) do
    case Modify.update_service(user, :nickname, new_nickname, Keyword.take(opts, [:repo])) do
      {:ok, user} -> user
      {:error, changeset} -> changeset
    end
  end

  # TODO: Wrap it.
  @spec username(Member.User.t(), String.t(), keyword()) ::
          {:ok, Member.User.t()} | {:error, any()}
  def username(user, new_username, opts \\ []) do
    case Modify.update_service(user, :username, new_username, Keyword.take(opts, [:repo])) do
      {:ok, user} -> user
      {:error, changeset} -> changeset
    end
  end

  @spec info(Member.User.t(), String.t(), keyword()) ::
          {:ok, Member.User.t()} | {:error, any()}
  def info(user, new_info, opts \\ []) do
    case Modify.update_service(user, :info, new_info, Keyword.take(opts, [:repo])) do
      {:ok, user} -> user
      {:error, changeset} -> changeset
    end
  end

  defmodule UsernameCollide do
    # TODO
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

  @spec timezone(User.t(), String.t() | charlist(), keyword()) ::
          {:ok, Member.User.Locale.t()} | {:error, any()}
  def timezone(%User{} = user, new_timezone, opts \\ []) do
    case Modify.update_service(
           user,
           :timezone,
           new_timezone,
           [locale: true] ++ Keyword.take(opts, [:repo])
         ) do
      {:ok, user} -> user
      {:error, changeset} -> changeset
    end
  end

  @spec language(User.t(), String.t() | charlist(), keyword()) ::
          {:ok, Member.User.Locale.t()} | {:error, any()}
  def language(%User{} = user, new_language, opts \\ []) do
    case Modify.update_service(
           user,
           :lang,
           new_language,
           [locale: true] ++ Keyword.take(opts, [:repo])
         ) do
      {:ok, user} -> user
      {:error, changeset} -> changeset
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

  defp parse_deps(opts) do
    {repo, opts} = Keyword.pop(opts, :repo, @default_repo)
    {pass_hash, _opts} = Keyword.pop(opts, :pass_hash, @default_hash)

    %{repo: repo, pass_hash: pass_hash}
  end

  ## 密码

  defp do_update_password(%User{} = user, new_password, opts) do
    %{repo: repo, pass_hash: hashlib} = parse_deps(opts)

    Modify.update_service(user, :password, hashlib.generate_hash(new_password), repo: repo)
  end

  # 通过命令
  def update_password_in_shell(%User{} = user, new_password, opts \\ []),
    do: do_update_password(user, new_password, opts)

  # 通过邮件认证
  def update_password_via_email(), do: nil

  # 通过邀请树

  ## 邮件

  # 通过命令

  # 通过邀请树
end

defmodule Member.Usecase.UpdateStatus do
  @moduledoc """
  更改用户的状态，因为其和信息不同的性质。
  """

  # alias Member.User
  # alias Member.User.{Status, Gender}
  # @default_repo MeowCave.Member

  def update_status(), do: nil
  def update_gender(), do: nil
  def hide_gender(), do: nil
  def expose_gender(), do: nil
end
