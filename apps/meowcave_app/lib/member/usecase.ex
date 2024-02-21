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

  @default_repo MeowCave.Member
  @default_hash MeowCave.Member.User.PassHash

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
  def update_service(%User{} = user, field, new_value, opts \\ []) do
    %{repo: repo, auth: auth, locale: locale} = parse_deps(opts)

    do_update_service(user, %{field => new_value}, repo, locale, auth)
  end

  defp do_update_service(%User{} = user, %{} = values, repo, locale, auth) do
    repo.update_user_info(user, values, locale, auth)
  end
end

defmodule Member.Usecase.ModifyUser do
  @moduledoc """
  修改用户信息的相关用例。

  包括昵称、用户名以及信息。
  """

  alias Member.Usecase.Modify

  def nickname(user, new_nickname, opts \\ []) do
    case Modify.update_service(user, :nickname, new_nickname, Keyword.take(opts, [:repo])) do
      {:ok, user} -> user
      {:error, changeset} -> changeset
    end
  end

  # TODO: Wrap it.
  def username(user, new_username, opts \\ []) do
    case Modify.update_service(user, :username, new_username, Keyword.take(opts, [:repo])) do
      {:ok, user} -> user
      {:error, changeset} -> changeset
    end
  end

  def info(user, new_info, opts \\ []) do
    case Modify.update_service(user, :info, new_info, Keyword.take(opts, [:repo])) do
      {:ok, user} -> user
      {:error, changeset} -> changeset
    end
  end

  defmodule Member.Usecase.ModifyUser.UsernameCollide do
    # TODO
  end
end

defmodule Member.Usecase.ModifyLocaleInfo do
  @moduledoc """
  和 `Member.Usecase.ModifyUser` 在应用层面不同，但是本质上是一样的。
  """

  alias Member.User
  alias Member.Usecase.Modify

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

  # 密码

  # 邮件
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
