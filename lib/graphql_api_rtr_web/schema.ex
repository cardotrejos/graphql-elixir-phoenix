defmodule GraphqlApiRtrWeb.Schema do
  use Absinthe.Schema
  alias GraphqlApiRtrWeb.Middlewares.{Authentication, HandleErrors}

  import_types GraphqlApiRtrWeb.Types.Preference
  import_types GraphqlApiRtrWeb.Types.User
  import_types GraphqlApiRtrWeb.Types.Request
  import_types GraphqlApiRtrWeb.Types.ResolverHit
  import_types GraphqlApiRtrWeb.Schema.Queries.Preference
  import_types GraphqlApiRtrWeb.Schema.Queries.User
  import_types GraphqlApiRtrWeb.Schema.Queries.ResolverHit
  import_types GraphqlApiRtrWeb.Schema.Mutations.Preference
  import_types GraphqlApiRtrWeb.Schema.Mutations.User
  import_types GraphqlApiRtrWeb.Schema.Subscriptions.Preference
  import_types GraphqlApiRtrWeb.Schema.Subscriptions.User

  query do
    import_fields :preference_queries
    import_fields :user_queries
    import_fields :resolver_hit_queries
  end

  mutation do
    import_fields :preference_mutations
    import_fields :user_mutations
  end

  subscription do
    import_fields :preference_subscriptions
    import_fields :user_subscriptions
  end

  def context(ctx) do
    source = Dataloader.Ecto.new(GraphqlApiRtr.Repo)
    dataloader = Dataloader.add_source(Dataloader.new(), GraphqlApiRtr.Accounts, source)

    Map.put(ctx, :loader, dataloader)
  end

  def plugins do
    [Absinthe.Middleware.Dataloader] ++ Absinthe.Plugin.defaults()
  end

  def middleware(middleware, _, %{identifier: :mutation}) do
    [Authentication | middleware] ++ [HandleErrors]
  end

  def middleware(middleware, _, %{identifier: identifier})
      when identifier in [:query, :subscription] do
    middleware ++ [HandleErrors]
  end

  def middleware(middleware, _, _) do
    middleware
  end
end
