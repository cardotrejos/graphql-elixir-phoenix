defmodule GraphqlApiRtrWeb.Types.Preference do
  @moduledoc false
  use Absinthe.Schema.Notation
  import Absinthe.Resolution.Helpers, only: [dataloader: 2]

  @desc "Notification preferences for a user- queries"
  object :preferences do
    field :id, non_null(:id)
    field :user_id, non_null(:id)
    field :likes_emails, non_null(:boolean)
    field :likes_phone_calls, non_null(:boolean)
    field :likes_faxes, non_null(:boolean)
    field :user, :user, resolve: dataloader(GraphqlApiRtr.Accounts, :user)
  end

  @desc "Notification preferences for a user - mutations"
  input_object :preference_input do
    field :likes_emails, non_null(:boolean)
    field :likes_phone_calls, non_null(:boolean)
    field :likes_faxes, non_null(:boolean)
  end
end
