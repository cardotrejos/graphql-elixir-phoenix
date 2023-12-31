defmodule GraphqlApiRtrWeb.Schema.Queries.UserTest do
  use GraphqlApiRtr.DataCase, async: true

  import GraphqlApiRtr.UserFixtures, only: [user: 1]
  alias GraphqlApiRtr.Accounts
  alias GraphqlApiRtrWeb.Schema

  @valid_preference_params %{likes_emails: false, likes_phone_calls: false, likes_faxes: false}

  setup [:user]

  @all_users_doc """
  query Users($likesEmails: Boolean, $likesPhoneCalls: Boolean, $likesFaxes: Boolean, $name: String, $before: Int, $after: Int, $first: Int ) {
    users (likesEmails: $likesEmails, likesPhoneCalls: $likesPhoneCalls, likesFaxes: $likesFaxes, name: $name, before: $before, after: $after, first: $first) {
      id
      name
      email
      preferences {
        id
        user_id
        likes_emails
        likes_phone_calls
        likes_faxes
      }
    }
  }
  """

  describe "@users" do
    test "fetches users by preferences", %{user: %{name: name, email: email, id: id}} do
      user_id = to_string(id)

      assert {
               :ok,
               %{
                 data: %{
                   "users" => [
                     %{
                       "id" => ^user_id,
                       "name" => ^name,
                       "email" => ^email,
                       "preferences" => %{
                         "likes_emails" => false,
                         "likes_faxes" => false,
                         "likes_phone_calls" => false,
                         "user_id" => ^user_id
                       }
                     }
                   ]
                 }
               }
             } = Absinthe.run(@all_users_doc, Schema, variables: %{"likesEmails" => false})
    end

    test "fetches the users after the n-th user", %{user: %{id: id}} do
      assert {:ok, user2} =
               %{name: "Bob", email: "spirit@skull.com"}
               |> Map.put(:preferences, @valid_preference_params)
               |> Accounts.create_user()

      assert {:ok, user3} =
               %{name: "Karen", email: "murphy@example.com"}
               |> Map.put(:preferences, @valid_preference_params)
               |> Accounts.create_user()

      user2_id = to_string(user2.id)
      user3_id = to_string(user3.id)

      assert {:ok,
              %{
                data: %{
                  "users" => [
                    %{
                      "email" => "spirit@skull.com",
                      "id" => ^user2_id,
                      "name" => "Bob",
                      "preferences" => %{
                        "likes_emails" => false,
                        "likes_faxes" => false,
                        "likes_phone_calls" => false,
                        "user_id" => ^user2_id
                      }
                    },
                    %{
                      "email" => "murphy@example.com",
                      "id" => ^user3_id,
                      "name" => "Karen",
                      "preferences" => %{
                        "likes_emails" => false,
                        "likes_faxes" => false,
                        "likes_phone_calls" => false,
                        "user_id" => ^user3_id
                      }
                    }
                  ]
                }
              }} = Absinthe.run(@all_users_doc, Schema, variables: %{"after" => id})
    end
  end

  @find_user_doc """
  query User($id: ID, $email: String ) {
    user (id: $id, email: $email) {
     id
     name
     email
    preferences {
      id
      user_id
      likes_emails
      likes_phone_calls
      likes_faxes
     }
    }
  }
  """

  describe "@user" do
    test "fetches a user based on their id", %{user: %{name: name, email: email, id: id}} do
      user_id = to_string(id)

      assert {
               :ok,
               %{
                 data: %{
                   "user" => %{
                     "id" => ^user_id,
                     "name" => ^name,
                     "email" => ^email,
                     "preferences" => %{
                       "likes_emails" => false,
                       "likes_faxes" => false,
                       "likes_phone_calls" => false,
                       "user_id" => ^user_id
                     }
                   }
                 }
               }
             } = Absinthe.run(@find_user_doc, Schema, variables: %{"id" => id})
    end

    test "fetches a user based on their email", %{user: %{name: name, email: email, id: id}} do
      user_id = to_string(id)

      assert {
               :ok,
               %{
                 data: %{
                   "user" => %{
                     "id" => ^user_id,
                     "name" => ^name,
                     "email" => ^email,
                     "preferences" => %{
                       "user_id" => ^user_id,
                       "likes_emails" => false,
                       "likes_faxes" => false,
                       "likes_phone_calls" => false
                     }
                   }
                 }
               }
             } = Absinthe.run(@find_user_doc, Schema, variables: %{"email" => email})
    end
  end
end
