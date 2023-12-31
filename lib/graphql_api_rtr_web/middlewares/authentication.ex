defmodule GraphqlApiRtrWeb.Middlewares.Authentication do
  @moduledoc false
  @behaviour Absinthe.Middleware
  @impl Absinthe.Middleware

  alias GraphqlApiRtr.Config

  @secret_key Config.secret_key()

  def call(%{context: %{secret_key: secret_key}} = resolution, _) do
    case secret_key do
      @secret_key -> resolution
      _ -> Absinthe.Resolution.put_result(resolution, {:error, "unauthenticated"})
    end
  end

  # This matches on what is pushed in the subscription tests
  if Mix.env() === :test do
    def call(%{context: %{pubsub: GraphqlApiRtrWeb.Endpoint}} = resolution, _) do
      resolution
    end
  end

  def call(resolution, _) do
    Absinthe.Resolution.put_result(resolution, {:error, "Please enter a secret key"})
  end
end
