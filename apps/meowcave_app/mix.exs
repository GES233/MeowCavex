defmodule MeowCaveApp.MixProject do
  use Mix.Project

  def project do
    [
      app: :meowcave_app,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: []
    ]
  end

  # 不同环境下有不同的路径。
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
