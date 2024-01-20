defmodule MeowCaveWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :meowcave_web

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  @session_options [
    store: :cookie,
    key: "_meowcave_web_key",
    signing_salt: "HzfEkj1U",
    same_site: "Lax"
  ]

  # TODO: Add @token_options

  socket "/live", Phoenix.LiveView.Socket, websocket: [connect_info: [session: @session_options]]

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: :meowcave_web,
    gzip: false,
    only: MeowCaveWeb.static_paths()

  # 代码重载将在你的端点配置的 :code_reloader 部分被明确的启用。
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
    plug Phoenix.Ecto.CheckRepoStatus, otp_app: :meowcave_web
  end

  plug Phoenix.LiveDashboard.RequestLogger,
    param_key: "request_logger",
    cookie_key: "request_logger"

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options

  # 将 Router 作为最后的一个 Plug（也就是说 Router 实在这些 Plug 的最后的）
  plug MeowCaveWeb.Router
end
