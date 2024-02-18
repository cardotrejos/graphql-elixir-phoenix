defmodule GraphqlApiRtrWeb.Schema.Subscriptions.AuthTokenTest do
  use GraphqlApiRtrWeb.SubscriptionCase
  import GraphqlApiRtr.UserFixtures, only: [user: 1]
  alias GraphqlApiRtr.TokenCache

  @auth_token_generated_doc """
  subscription AuthTokenGenerated($user_id: ID!) {
    authTokenGenerated(user_id: $user_id) {
      user_id
      token
      timestamp
    }
  }
  """

  @token "FakeToken"
  @timestamp DateTime.utc_now()

  setup :user

  describe "@auth_token_generated" do
    test "broadcasts when an auth_token for the given ID is generated", %{
      socket: socket,
      user: %{id: id}
    } do
      string_id = to_string(id)
      ref = push_doc(socket, @auth_token_generated_doc, variables: %{"user_id" => string_id})

      assert_reply ref, :ok, %{subscriptionId: subscription_id}
      TokenCache.put(id, %{token: @token, timestamp: @timestamp})
      assert_push("subscription:data", data)

      assert %{
               subscriptionId: ^subscription_id,
               result: %{
                 data: %{
                   "authTokenGenerated" => %{
                     "timestamp" => timestamp,
                     "token" => @token,
                     "user_id" => ^string_id
                   }
                 }
               }
             } = data

      assert {:ok, @timestamp, 0} === DateTime.from_iso8601(timestamp)
    end
  end
end
