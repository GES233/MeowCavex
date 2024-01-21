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

  @spec call(String.t(), String.t(), String.t(), charlist(), charlist(), keyword(module())) :: User.t()
  def call(nickname, email, password, lang \\ "zh-Hans", timezone \\ "Etc/UTC", opts \\ []) do
    {hashlib, opts} = Keyword.pop(opts, :pass_hash, @default_hash)

    locale_field = Register.create_locale(lang, timezone)

    auth_field = %{
      Register.create_auth(nickname, email, password)
      | hashed_password: hashlib.generate_hash(password)
    }

    {repo, _opts} = Keyword.pop(opts, :repo, @default_repo)

    {status, user_or_changeset} = repo.create(auth_field, locale_field)

    case status do
      :ok -> user_or_changeset
      :error
      -> case user_or_changeset do
        # TODO: 仔细看下 Ecto.insert 的错误格式
        _ -> raise Register.EmailCollide, auth_field.email
      end
    end
  end
end

defmodule Member.Usecase.ModifyInfo do
  @moduledoc """
  修改用户的信息。
  """

  # @default_repo MeowCave.Member
end

defmodule Member.Usecase.UpdateStatus do
  @moduledoc """
  更改用户的状态，因为其和信息不同的性质。
  """

  # alias Member.User
  # alias Member.User.Status
  # @default_repo MeowCave.Member

  def update_status(), do: nil
  def update_gender(), do: nil
  def hide_gender(), do: nil
  def expose_gender(), do: nil
end
