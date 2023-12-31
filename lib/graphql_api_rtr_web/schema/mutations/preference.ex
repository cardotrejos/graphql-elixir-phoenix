defmodule GraphqlApiRtrWeb.Schema.Mutations.Preference do
  @moduledoc false
  use Absinthe.Schema.Notation
  alias GraphqlApiRtrWeb.Resolvers

  object :preference_mutations do
    @desc "Updates a user's notification preferences"
    field :update_user_preferences, :preferences do
      arg :user_id, non_null(:id)
      arg :likes_emails, :boolean
      arg :likes_phone_calls, :boolean
      arg :likes_faxes, :boolean

      resolve &Resolvers.Preference.update_user_preferences/2
    end
  end
end
