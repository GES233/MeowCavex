defmodule MeowCaveWeb.KickGuestOut do
  @moduledoc """
  将非注册的用户跳转至首页/或返回 401/403/404 。

  ## Example

      plug MeowCaveWeb.KickGuestOut

  """

  # 参考了 https://elixirforum.com/t/mix-phx-gen-auth-stuck/51066/3
  # 中 @derpycoder 的回复。

  @behaviour Plug
  # import Plug.Conn
  # alias Phoenix.Controller
  # use Gettext, backend: MeowCaveWeb.Gettext

  @impl true
  def init(opts), do: opts
  # TODO: 从配置中读取是返回 401/403/404 还是直接跳转回主页？

  @impl true
  @spec call(Plug.Conn.t(), any()) :: Plug.Conn.t()
  def call(conn, _opts) do
    conn.assigns.current_user
    |> is_member?()
    |> halt_when_not_user(conn)
  end

  defp is_member?(_user), do: true

  defp halt_when_not_user(true, conn), do: conn
  # defp halt_when_not_user(false, conn), do: nil
end
