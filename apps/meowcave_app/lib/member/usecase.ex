defmodule Member.Usecase do
  # TODO: integrate all usecases.
end

defmodule Member.Usecase.Register do
  def call(_a, _b), do: nil
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
