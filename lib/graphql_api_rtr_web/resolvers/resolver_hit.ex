defmodule GraphqlApiRtrWeb.Resolvers.ResolverHit do
  @moduledoc false

  alias GraphqlApiRtr.HitCounter

  def get_hits(%{key: key}, _) do
    HitCounter.add_hit(:resolver_hits)
    count = HitCounter.get_hits(key)
    {:ok, %{key: key, count: count}}
  end
end
