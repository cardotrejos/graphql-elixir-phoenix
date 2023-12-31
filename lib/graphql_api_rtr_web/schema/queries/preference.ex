defmodule GraphqlApiRtrWeb.Schema.Queries.Preference do
  @moduledoc false
  use Absinthe.Schema.Notation
  alias GraphqlApiRtrWeb.Resolvers

  object :preference_queries do
    @desc "Returns a list of all preferences filtered based on the given params"
    field :preferences, list_of(:preferences) do
      arg :likes_emails, :boolean
      arg :likes_phone_calls, :boolean
      arg :likes_faxes, :boolean

      arg :before, :integer
      arg :after, :integer
      arg :first, :integer

      resolve &Resolvers.Preference.all/2
    end

    @desc "Returns the preferences for a specific user based on the user_id"
    field :user_preferences, :preferences do
      arg :user_id, non_null(:id)

      resolve &Resolvers.Preference.find_user_preferences/2
    end
  end
end
