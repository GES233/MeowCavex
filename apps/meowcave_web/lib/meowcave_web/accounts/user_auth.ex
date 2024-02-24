defmodule MeowCaveWeb.Accounts.UserAuth do
  @moduledoc """
  逐行抄袭了 `phx.gen.auth` 的内容，但是选择了领域模型。
  """
  use MeowCaveWeb, :verified_routes

  # import Plug.Conn
  # import Phoenix.Controller

  # alias Member.User
  # alias MeowCave.Member.UserRepo

  def user_login(conn, _user, _param \\ %{}), do: conn
  def user_logout(conn), do: conn
  def fetch_current_user(conn, _opts), do: conn
end
