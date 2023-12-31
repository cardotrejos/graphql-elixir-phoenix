defmodule GraphqlApiRtrWeb.Schema.Queries.PreferenceTest do
  use GraphqlApiRtr.DataCase

  import GraphqlApiRtr.UserFixtures, only: [user: 1]
  alias GraphqlApiRtr.Accounts
  alias GraphqlApiRtrWeb.Schema

  @valid_preference_params %{likes_emails: false, likes_phone_calls: false, likes_faxes: false}

  setup :user

  @all_preferences_doc """
  query Preferences($likesEmails: Boolean, $likesPhoneCalls: Boolean, $likesFaxes: Boolean, $before: Int, $after: Int, $first: Int ) {
    preferences (likesEmails: $likesEmails, likesPhoneCalls: $likesPhoneCalls, likesFaxes: $likesFaxes, before: $before, after: $after, first: $first) {
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

  describe "@preferences" do
    test "fetches all sets of preferences based on a given preference filter", %{
      user: %{name: name, email: email, id: id}
    } do
      user_id = to_string(id)

      assert {
               :ok,
               %{
                 data: %{
                   "preferences" => [
                     %{
                       "likesEmails" => false,
                       "likesFaxes" => false,
                       "likesPhoneCalls" => false,
                       "user" => %{
                         "email" => ^email,
                         "id" => ^user_id,
                         "name" => ^name
                       },
                       "userId" => ^user_id
                     }
                   ]
                 }
               }
             } = Absinthe.run(@all_preferences_doc, Schema, variables: %{"likesEmails" => false})
    end

    test "fetches the first n sets of preferences", %{user: %{name: name, email: email, id: id}} do
      assert {:ok, user2} =
               %{name: "Bob", email: "spirit@skull.com"}
               |> Map.put(:preferences, @valid_preference_params)
               |> Accounts.create_user()

      assert {:ok, _user3} =
               %{name: "Karen", email: "murphy@example.com"}
               |> Map.put(:preferences, @valid_preference_params)
               |> Accounts.create_user()

      user1_id = to_string(id)
      user2_id = to_string(user2.id)

      assert {
               :ok,
               %{
                 data: %{
                   "preferences" => [
                     %{
                       "likesEmails" => false,
                       "likesFaxes" => false,
                       "likesPhoneCalls" => false,
                       "user" => %{
                         "email" => ^email,
                         "id" => ^user1_id,
                         "name" => ^name
                       },
                       "userId" => ^user1_id
                     },
                     %{
                       "likesEmails" => false,
                       "likesFaxes" => false,
                       "likesPhoneCalls" => false,
                       "user" => %{
                         "email" => "spirit@skull.com",
                         "id" => ^user2_id,
                         "name" => "Bob"
                       },
                       "userId" => ^user2_id
                     }
                   ]
                 }
               }
             } =
               Absinthe.run(@all_preferences_doc, Schema,
                 variables: %{"likesEmails" => false, "first" => 2}
               )
    end
  end

  @find_user_preferences_doc """
  query UserPreferences($userId: ID!){
    userPreferences (userId: $userId) {
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

  describe "@user_preferences" do
    test "fetches a set of preferences based on the user_id", %{
      user: %{name: name, email: email, id: id}
    } do
      user_id = to_string(id)

      assert {
               :ok,
               %{
                 data: %{
                   "userPreferences" => %{
                     "likesEmails" => false,
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
             } = Absinthe.run(@find_user_preferences_doc, Schema, variables: %{"userId" => id})
    end
  end
end
