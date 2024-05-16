defmodule MeowCaveWeb.Plugs.Locale do
  @moduledoc """
  关于本地化（包括语言和时区）。

  关于语言与时区的选择：

  * 语言：用户选择 > 请求头的 `Accept-Language`
  * 时区：暂时放弃

  其中，用户的选择通过请求中的 Cookie `Locale` 来保存。
  """

  @behaviour Plug

  @impl true
  def init(opts), do: opts

  @impl true
  @spec call(Plug.Conn.t(), any()) :: Plug.Conn.t()
  def call(conn, _opts) do
    conn
    # 有相关 Header/Cookie => 从对应的 Header/Cookie 中获取
    # 无定位相关 Header 但是可以确定用户身份 => 从数据库中获取
    # 查无此人（无相关 Cookie/Header） => 从请求头中获取
    # 选择默认

    # 如果没有的话，将经过查询的结果写入 Cookie
  end

  @valid_locales Application.compile_env(:meowcave_web, MeowCaveWeb.Gettext, :locales)

  def get_valid_locales, do: @valid_locales

  # @cookie_key "Locale"

  # defp from_param(), do: nil
  # defp from_headers(%Plug.Conn{req_headers: headers} = _conn), do: headers
  # defp from_cookie(%Plug.Conn{} = _conn), do: nil
  # defp from_database(), do: nil

  # defp has_locale_cookie?(_conn), do: false
  # defp has_auth_cookie?(_conn), do: true
end
