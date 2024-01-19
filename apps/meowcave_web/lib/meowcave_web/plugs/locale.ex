defmodule MeowcaveWeb.Plug.Locale do
  @moduledoc """
  关于本地化（包括语言和时区）。
  """
  @behaviour Plug

  def init(opts), do: opts

  def call(conn, _opts) do
    conn
    # 设置有有相关 Header/Cookie => 从对应的 Header/Cookie 中获取
    # 查无此人（无相关 Cookie/Header） => 从请求头中获取
    # 无要求 => 从用户的信息中（数据库）获取
    # 选择默认
  end
end
