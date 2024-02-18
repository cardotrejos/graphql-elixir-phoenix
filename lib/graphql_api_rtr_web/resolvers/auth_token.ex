defmodule GraphqlApiRtrWeb.Resolvers.AuthToken do
  @moduledoc false

  alias GraphqlApiRtr.{HitCounter, TokenCache}

  def get_auth_token(%{user_id: user_id}, _) do
    HitCounter.add_hit(:auth_token)

    user_id
    |> String.to_integer()
    |> retrieve_token_from_cache()
  end

  def find_user_token(%{id: id}, _, _) do
    retrieve_token_from_cache(id)
  end

  defp retrieve_token_from_cache(user_id) do
    case TokenCache.get(user_id) do
      nil ->
        {:ok, nil}

      %{token: _token, timestamp: _timestamp} = auth_token ->
        {:ok, Map.merge(auth_token, %{user_id: user_id})}
    end
  end
end
