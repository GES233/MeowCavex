import Config

# 请注意，我们还包含了缓存清单的路径，
# 其中包含静态文件的摘要版本（digested version）。
# 该清单由 `mix phx.digest` 任务生成，
# 应在生成静态文件后、启动生产服务器之前运行该任务。
config :meowcave_web, MeowCaveWeb.Endpoint,
  url: [host: "meowcave.moe", port: 80],
  cache_static_manifest: "priv/static/cache_manifest.json"

# 配置 Swooch API 客户端
config :swoosh, :api_client, MeowCave.Finch

# 禁用 Swoosh 本地的 LocalStoage
# （Disable Swoosh Local Memory Storage）
config :swoosh, local: false

# 不要再生产环境下打印 debug 信息
config :logger, level: :info

# 运行时的生产配置，包括环境变量的读取，
# 在 config/runtime.exs 中完成。
