defmodule GraphqlApiRtrWeb.Schema.Subscriptions.UserTest do
  use GraphqlApiRtrWeb.SubscriptionCase

  @preferences %{likes_emails: false, likes_phone_calls: false, likes_faxes: false}

  @create_user_doc """
    mutation CreateUser($name: String!, $email: String!, $preferences: PreferenceInput!){
    createUser (name: $name, email: $email, preferences: $preferences) {

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

  @created_user_doc """
  subscription CreatedUser {
   createdUser {
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

  describe "@created_user" do
    test "sends a user when @createdUser mutation is triggered", %{socket: socket} do
      ref = push_doc(socket, @created_user_doc, variables: %{})

      assert_reply ref, :ok, %{subscriptionId: subscription_id}

      ref =
        push_doc(socket, @create_user_doc,
          variables: %{
            "name" => "Waldo",
            "email" => "butters@example.com",
            "preferences" => @preferences
          }
        )

      assert_reply ref, :ok, reply

      assert %{
               data: %{
                 "createUser" => %{
                   "name" => "Waldo",
                   "email" => "butters@example.com",
                   "preferences" => %{
                     "likes_emails" => false,
                     "likes_faxes" => false,
                     "likes_phone_calls" => false
                   }
                 }
               }
             } = reply

      assert_push "subscription:data", data

      assert %{
               subscriptionId: ^subscription_id,
               result: %{
                 data: %{
                   "createdUser" => %{
                     "name" => "Waldo",
                     "email" => "butters@example.com",
                     "preferences" => %{
                       "likes_emails" => false,
                       "likes_faxes" => false,
                       "likes_phone_calls" => false
                     }
                   }
                 }
               }
             } = data
    end
  end
end
