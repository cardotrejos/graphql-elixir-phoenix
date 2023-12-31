defmodule GraphqlApiRtrWeb.Types.ResolverHit do
  @moduledoc false
  use Absinthe.Schema.Notation

  @desc "The number of times the GraphQL Server is hit with a given request"
  object :resolver_hit do
    field :key, non_null(:request)
    field :count, non_null(:integer)
  end
end
