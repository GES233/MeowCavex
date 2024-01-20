defmodule MeowCave.Umbrella.MixProject do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      version: "0.1.0",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      compilers: [:leex] ++ Mix.compilers()
      # in order to compile .xrl files, you must add
      # "compilers: [:leex] ++ Mix.compilers()"
      # to the "def project" section of your mix.exs
    ]
  end

  # 此处列出的依赖项仅适用于本项目，不能从 apps/ 文件夹内的应用程序访问。
  defp deps do
    [
      # 需要在雨伞项目的根目录的 ~H/.heex 文件运行 "mix format"
      {:phoenix_live_view, ">= 0.0.0"}
    ]
  end

  # 此处列出的别名仅适用于本项目，不能从 apps/ 文件夹内的应用程序访问。
  defp aliases do
    [
      # 运行 `apps` 内所有子应用的 `mix setup`
      setup: ["cmd mix setup"]
    ]
  end
end
