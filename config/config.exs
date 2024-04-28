# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :graphql_api_rtr,
  ecto_repos: [GraphqlApiRtr.Repo],
  secret_key: "ThisIsAReallySecretKeySecureAndReliable",
  token_max_age: %{unit: :hour, amount: 24},
  producer_sleep_time: 10_000

config :ecto_shorts,
  repo: GraphqlApiRtr.Repo,
  error_module: EctoShorts.Actions.Error

# Configures the endpoint
config :graphql_api_rtr, GraphqlApiRtrWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [json: GraphqlApiRtrWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: GraphqlApiRtr.PubSub,
  live_view: [signing_salt: "13Zl8Tw8"]

config :request_cache_plug, request_cache_module: GraphqlApiRtr.RedisCache

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :graphql_api_rtr, GraphqlApiRtr.Mailer, adapter: Swoosh.Adapters.Local

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
