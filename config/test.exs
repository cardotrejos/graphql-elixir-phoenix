import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.

config :graphql_api_rtr, GraphqlApiRtr.Repo,
  username: "postgres",
  hostname: "localhost",
  database: "graphql_api_rtr_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

config :graphql_api_rtr, GraphqlApiRtrWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "YLzkiUbLsQ1FuLZSIQiIrYB8V+hGgJKsRBznWIqLjsH53tPLMCYo60ZEOP5d7h91",
  server: false

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

config :graphql_api_rtr,
  producer_sleep_time: 10

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
