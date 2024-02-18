defmodule GraphqlApiRtrWeb.Types.AuthToken do
  @moduledoc false
  use Absinthe.Schema.Notation

  @desc "An auth token for a user"
  object :auth_token do
    field :user_id, non_null(:id)
    field :timestamp, non_null(:datetime)
    field :token, non_null(:string)
  end
end
