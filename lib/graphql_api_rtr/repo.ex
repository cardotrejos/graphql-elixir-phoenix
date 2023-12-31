defmodule GraphqlApiRtr.Repo do
  use Ecto.Repo,
    otp_app: :graphql_api_rtr,
    adapter: Ecto.Adapters.Postgres
end
