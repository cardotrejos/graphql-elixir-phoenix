defmodule GraphqlApiRtrWeb.Schema.Subscriptions.User do
  @moduledoc false
  use Absinthe.Schema.Notation

  object :user_subscriptions do
    @desc "Broadcasts newly created user"
    field :created_user, :user do
      config fn _, _ -> {:ok, topic: "new user"} end

      trigger :create_user, topic: fn _ -> "new user" end
    end
  end
end
