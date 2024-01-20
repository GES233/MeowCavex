defmodule Member.Usecase do
  # TODO: integrate all usecases.
end

defmodule Member.Usecase.Register do
  @moduledoc """
  关于注册的用例。

  ## Example

      Member.Usecase.Register.call(..., repo: MeowCave.Member)

  """
  alias Member.Service.Register

  @default_repo MeowCave.Member
  @default_hash MeowCave.Member.User.PassHash

  def call(nickname, email, password, lang \\ "zh-Hans", timezone \\ "Etc/UTC", opts \\ []) do
    {hashlib, opts} = Keyword.pop(opts, :pass_hash, @default_hash)

    locale_field = Register.create_locale(lang, timezone)

    auth_field = %{
      Register.create_auth(nickname, email, password)
      | hashed_password: hashlib.generate_hash(password)
    }

    {repo, _opts} = Keyword.pop(opts, :repo, @default_repo)

    repo.create(auth_field, locale_field)
  end
end

defmodule Member.Usecase.ModifyInfo do
  @moduledoc """
  修改用户的信息。
  """
end

defmodule Member.Usecase.UpdateStatus do
  @moduledoc """
  更改用户的状态，因为其和信息不同的性质。
  """
end
