defmodule GraphqlApiRtr.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  @spec start(any, any) :: {:error, any} | {:ok, pid}
  def start(_type, _args) do

    GraphqlApiRtr.HitCounter.setup_counter()

    children = [
      # Start the Telemetry supervisor
      GraphqlApiRtrWeb.Telemetry,
      {Phoenix.PubSub, name: GraphqlApiRtr.PubSub},
      GraphqlApiRtrWeb.Endpoint,
      {Absinthe.Subscription, GraphqlApiRtrWeb.Endpoint},
      {Finch, name: GraphqlApiRtr.Finch},
      # Start a worker by calling: GraphqlApiRtr.Worker.start_link(arg)
      # {GraphqlApiRtr.Worker, arg}
      GraphqlApiRtr.Repo
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: GraphqlApiRtr.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    GraphqlApiRtrWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
