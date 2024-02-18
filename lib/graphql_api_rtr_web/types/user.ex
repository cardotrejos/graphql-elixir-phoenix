defmodule GraphqlApiRtrWeb.Types.User do
  @moduledoc false
  use Absinthe.Schema.Notation

  import Absinthe.Resolution.Helpers, only: [dataloader: 2]
  alias GraphqlApiRtrWeb.Resolvers

  @desc "A user with notification preferences"
  object :user do
    field :id, non_null(:id)
    field :name, non_null(:string)
    field :email, non_null(:string)

    field :auth_token, :auth_token do
      resolve &Resolvers.AuthToken.find_user_token/3
    end

    field :preferences, non_null(:preferences),
      resolve: dataloader(GraphqlApiRtr.Accounts, :preferences)
  end
end
