defmodule GraphqlApiRtrWeb.Schema.Queries.AuthToken do
  @moduledoc false
  use Absinthe.Schema.Notation
  alias GraphqlApiRtrWeb.Resolvers

  object :auth_token_queries do
    @desc "Returns the auth token for a given user id"
    field :auth_token, :auth_token do
      arg :user_id, non_null(:id)

      resolve &Resolvers.AuthToken.get_auth_token/2
    end
  end
end
