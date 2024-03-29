defmodule MeowCave.MixProject do
  use Mix.Project

  def project do
    [
      app: :meowcave,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {MeowCave.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:dns_cluster, "~> 0.1.1"},
      # Phoenix 的分布式相关
      {:phoenix_pubsub, "~> 2.1"},
      # 数据库
      {:ecto_sql, "~> 3.10"},
      {:postgrex, ">= 0.0.0"},
      # JSON 解析
      {:jason, "~> 1.2"},
      # 邮件客户端
      {:swoosh, "~> 1.3"},
      # HTTP 客户端
      {:finch, "~> 0.13"},
      # 密码混淆
      {:comeonin, "~> 5.4"},
      {:pbkdf2_elixir, "~> 2.2"},
      # MeowCaveApp
      {:meowcave_app, in_umbrella: true}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"]
    ]
  end
end
