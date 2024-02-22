# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of the Config module.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
import Config

# Configure Mix tasks and generators
config :meowcave,
  namespace: MeowCave,
  ecto_repos: [MeowCave.Repo]

# Configure the Repo
config :meowcave, MeowCave.Repo, migration_timestamps: [type: :utc_datetime]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :meowcave, MeowCave.Mailer, adapter: Swoosh.Adapters.Local

config :meowcave_web,
  namespace: MeowCaveWeb,
  ecto_repos: [MeowCave.Repo],
  generators: [context_app: :meowcave]

# Configures the endpoint
config :meowcave_web, MeowCaveWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: MeowCaveWeb.ErrorHTML, json: MeowCaveWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: MeowCave.PubSub,
  live_view: [signing_salt: "eFbB+RKP"]

# Locale
# default: Chinese.
config :meowcave_web, MeowCaveWeb.Gettext,
  locales: ~w(en zh-Hans),
  default_locale: "zh_Hans"

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../apps/meowcave_web/assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.3.2",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../apps/meowcave_web/assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

## Application related
config :meowcave_app, :default_ports,
  user_repo: MeowCave.Member.UserRepo,
  password_hash: MeowCave.Member.User.PassHash

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
