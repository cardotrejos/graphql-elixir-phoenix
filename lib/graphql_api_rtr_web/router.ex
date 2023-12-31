defmodule GraphqlApiRtrWeb.Router do
  use GraphqlApiRtrWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug GraphqlApiRtrWeb.AuthPlug
  end

  scope "/" do
    pipe_through :api

    forward "/graphql", Absinthe.Plug, schema: GraphqlApiRtrWeb.Schema

    if Mix.env() == :dev do
      forward "/graphiql", Absinthe.Plug.GraphiQL,
        interface: :playground,
        schema: GraphqlApiRtrWeb.Schema,
        socket: GraphqlApiRtrWeb.UserSocket
    end
  end
end
