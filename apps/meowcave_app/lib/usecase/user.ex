defmodule Usecase.User do
  # TODO: integrate all usecases.
end

defmodule Usecase.User.Register do
  def call(_a, _b), do: nil
end

defmodule Usecase.User.ModifyInfo do
  @moduledoc """
  修改用户的信息。
  """
end

defmodule Usecase.User.UpdateStatus do
  @moduledoc """
  更改用户的状态，因为其和信息不同的性质。
  """
end
