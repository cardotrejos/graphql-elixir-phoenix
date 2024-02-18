defmodule GraphqlApiRtrWeb.Schema.Queries.AuthTokenTest do
  use GraphqlApiRtr.DataCase, async: true

  import GraphqlApiRtr.UserFixtures, only: [user: 1, cache_entry: 1]

  alias GraphqlApiRtrWeb.Schema

  setup [:user, :cache_entry]

  @get_auth_token_doc """
  query AuthToken($user_id: ID!) {
    authToken (user_id: $user_id) {
      user_id
      timestamp
      token
    }
  }
  """

  describe "@auth_token" do
    test "returns the auth_token for a user", %{user: %{id: id}} do
      user_id = to_string(id)

      assert {:ok,
              %{
                data: %{
                  "authToken" => %{
                    "timestamp" => _timestamp,
                    "token" => "FakeToken",
                    "user_id" => ^user_id
                  }
                }
              }} = Absinthe.run(@get_auth_token_doc, Schema, variables: %{"user_id" => id})
    end
  end

  test "returns nil for the auth_token when auth_token for a user does not exist" do
    assert {:ok, %{data: %{"authToken" => nil}}} =
             Absinthe.run(@get_auth_token_doc, Schema, variables: %{"user_id" => 0})
  end
end
