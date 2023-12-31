defmodule GraphqlApiRtr.Config do
  @moduledoc """
  Fetches the environmental variables from the config.exs file
  """

  @app :graphql_api_rtr

  def secret_key do
    case Application.fetch_env(@app, :secret_key) do
      {:ok, value} -> value
      :error -> raise "Secret key not found for #{@app}"
    end
  end

  def token_max_age do
    Application.fetch_env!(@app, :token_max_age)
  end
end
