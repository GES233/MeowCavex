import Config

# 配置你的数据库
#
# MIX_TEST_PARTITION 环境变量可用于在 CI 环境中提供内置测试分区。
# 运行 `mix help test` 以获得更多信息。
config :meowcave, MeowCave.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "meowcave_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# 我们不在测试时启动服务器。
# 如果你需要的话，你可以启用以下的服务器设置。
config :meowcave_web, MeowCaveWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "392ykBPPPbyCxYKJsZ6J4NS6abGWqLfsomat2AmM9bd0hY7T5x3mX3d8MNWNYkYl",
  server: false

# 只在测试环境下打印警告以及错误
config :logger, level: :warning

# 我们在测试环境不发送邮件。
config :meowcave, MeowCave.Mailer, adapter: Swoosh.Adapters.Test

# 禁用 Swoosh API 客户端，因为只有生产适配器才需要它。
config :swoosh, :api_client, false

# 为加快测试环境下的编译，在运行时初始化 plug
config :phoenix, :plug_init_mode, :runtime

# 测试环境不用那么多次的加密
config :pbkdf2_elixir, :rounds, 1
