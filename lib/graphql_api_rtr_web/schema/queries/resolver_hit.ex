defmodule GraphqlApiRtrWeb.Schema.Queries.ResolverHit do
  @moduledoc false

  use Absinthe.Schema.Notation
  alias GraphqlApiRtrWeb.Resolvers

  object :resolver_hit_queries do
    @desc "Returns how often the GraphQL server has been hit with a given request"
    field :resolver_hits, :resolver_hit do
      arg :key, non_null(:request)

      resolve &Resolvers.ResolverHit.get_hits/2
    end
  end
end
