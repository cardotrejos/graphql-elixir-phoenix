defmodule GraphqlApiRtrWeb.Schema.Subscriptions.AuthToken do
  @moduledoc false
  use Absinthe.Schema.Notation

  object :auth_token_subscriptions do
    @desc "Broadcasts when a new auth token is generated for a user"
    field :auth_token_generated, :auth_token do
      arg :user_id, non_null(:id)

      config fn %{user_id: user_id}, _ -> {:ok, topic: "user_auth_token_generated:#{user_id}"} end
    end
  end
end
