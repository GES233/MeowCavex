defmodule MeowCave.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      MeowCave.Repo,
      {DNSCluster, query: Application.get_env(:meowcave, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: MeowCave.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: MeowCave.Finch}
      # Start a worker by calling: MeowCave.Worker.start_link(arg)
      # {MeowCave.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: MeowCave.Supervisor)
  end
end
