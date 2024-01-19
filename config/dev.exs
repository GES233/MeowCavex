import Config

# 配置你的数据库
config :meowcave, MeowCave.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "meowcave_dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

# 开发时，我们仅用了任何缓存并且启用了 debug 以及代码重载。
#
# 观察者配置可用于为应用程序运行外部观察者。
# 比方说，我们可以用它来捆绑 .js 和 .css 源。
config :meowcave_web, MeowCaveWeb.Endpoint,
  # 绑定到 loopback ipv4 地址会阻止其他机器的访问。更改为 `ip: {0, 0, 0, 0}` 以允许从其他机器访问。
  http: [ip: {127, 0, 0, 1}, port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "opBP5EiXSvPcPium285dRAPvdbOvLiHab3ksXk+/HKiIlDKx+AL8gI4h6OmprApb",
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:default, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:default, ~w(--watch)]}
  ]

# ## SSL 支持
#
# 为了在开发过程中使用 HTTPS，可通过运行以下 Mix 任务生成自签名证书：
#
#     mix phx.gen.cert
#
# 运行 `mix help phx.gen.cert` 可查看更多信息。
#
# 以上的 `http:` 的配置可被取代为：
#
#     https: [
#       port: 4001,
#       cipher_suite: :strong,
#       keyfile: "priv/cert/selfsigned_key.pem",
#       certfile: "priv/cert/selfsigned.pem"
#     ],
#
# 如果需要，`http:` 和 `https:`
# 键都可以配置为在不同端口上运行 http 和 https 服务器。

# 监视静态资源和模板的浏览器重载。
config :meowcave_web, MeowCaveWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/meowcave_web/(controllers|live|components)/.*(ex|heex)$"
    ]
  ]

# 启用开发时的主控板以及邮件的路由
config :meowcave_web, dev_routes: true

# 不要再开发日志里包括元数据以及时间戳
config :logger, :console, format: "[$level] $message\n"

# 为加快开发环境下的编译在运行时初始化 plug
config :phoenix, :plug_init_mode, :runtime

# 将 HEEx 的 debug 注释作为 HTML 注释包含在渲染的标记中
config :phoenix_live_view, :debug_heex_annotations, true

# 禁用 Swoosh API 客户端，因为只有生产适配器才需要它。
config :swoosh, :api_client, false

# 在开发时设置一个比较大的 stacktrace 大小。但是不要在生产环境这样做，因为成本可能会很高。
config :phoenix, :stacktrace_depth, 20
