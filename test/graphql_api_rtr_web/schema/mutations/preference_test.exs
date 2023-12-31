defmodule GraphqlApiRtrWeb.Schema.Mutations.PreferenceTest do
  use GraphqlApiRtr.DataCase, async: true

  import GraphqlApiRtr.UserFixtures, only: [user: 1]
  alias GraphqlApiRtr.{Accounts, Config}
  alias GraphqlApiRtrWeb.Schema

  @secret_key Config.secret_key()

  @update_user_preferences_doc """
  mutation UpdateUserPreferences($userId: ID!, $likesEmails: Boolean, $likesPhoneCalls: Boolean, $likesFaxes: Boolean) {
    updateUserPreferences (userId: $userId, likesEmails: $likesEmails, likesPhoneCalls: $likesPhoneCalls, likesFaxes: $likesFaxes) {
      id
      userId
      likesEmails
      likesPhoneCalls
      likesFaxes
      user {
        name
        email
        id
      }
    }
  }
  """

  describe "@update_user_preferences" do
    setup :user

    test "updates user preferences based on the user_id", %{
      user: %{name: name, email: email, id: id}
    } do
      user_id = to_string(id)

      assert {
               :ok,
               %{
                 data: %{
                   "updateUserPreferences" => %{
                     "likesEmails" => true,
                     "likesFaxes" => false,
                     "likesPhoneCalls" => false,
                     "user" => %{
                       "email" => ^email,
                       "id" => ^user_id,
                       "name" => ^name
                     },
                     "userId" => ^user_id
                   }
                 }
               }
             } =
               Absinthe.run(@update_user_preferences_doc, Schema,
                 variables: %{"userId" => id, "likesEmails" => true},
                 context: %{secret_key: @secret_key}
               )

      assert {:ok,
              %{likes_emails: true, likes_faxes: false, likes_phone_calls: false, user_id: ^id}} =
               Accounts.find_preferences(%{user_id: id})
    end

    test "returns error when no secret key is provided", %{
      user: %{id: id}
    } do
      assert {:ok,
              %{
                data: %{"updateUserPreferences" => nil},
                errors: [
                  %{
                    message: "Internal server error",
                    path: ["updateUserPreferences"],
                    code: :internal_server_error,
                    details: %{error: "\"Please enter a secret key\""}
                  }
                ]
              }} =
               Absinthe.run(@update_user_preferences_doc, Schema,
                 variables: %{"userId" => id, "likesEmails" => true}
               )
    end
  end
end
