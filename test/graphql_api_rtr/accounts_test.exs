defmodule GraphqlApiRtr.AccountsTest do
  use GraphqlApiRtr.DataCase, async: true
  import GraphqlApiRtr.UserFixtures, only: [user: 1]

  alias GraphqlApiRtr.{Accounts, Repo}
  alias GraphqlApiRtr.Accounts.{Preference, User}

  @valid_user_params %{name: "Harry", email: "dresden@example.com"}
  @valid_preference_params %{likes_emails: false, likes_phone_calls: false, likes_faxes: false}

  describe "all_users/1" do
    setup :user

    test "returns a list of all users when no parameters are given", %{
      user: %{id: id, name: name, email: email}
    } do
      assert [%User{id: ^id, name: ^name, email: ^email}] = Accounts.all_users(%{})
    end

    test "returns a list of all users matching the given parameter(s)", %{
      user: %{id: id, name: name, email: email}
    } do
      assert [%User{id: ^id, name: ^name, email: ^email}] =
               Accounts.all_users(%{likes_emails: false, name: name})

      assert [%User{id: ^id, name: ^name, email: ^email}] =
               Accounts.all_users(%{likes_emails: false, likes_phone_calls: false})
    end
  end

  describe "find_user/1" do
    setup :user

    test "returns a a tuple with :ok and the corresponding user when a matching user exists", %{
      user: %{id: id, name: name, email: email}
    } do
      assert {:ok, %User{id: ^id, name: ^name, email: ^email}} = Accounts.find_user(%{id: id})
    end

    test "returns a a tuple with :ok and the corresponding user when several parameters are given",
         %{
           user: %{id: id, name: name, email: email}
         } do
      assert {:ok, %User{id: ^id, name: ^name, email: ^email}} =
               Accounts.find_user(%{id: id, name: name})
    end

    test "returns a tuple with :error and reason when no search params are given" do
      assert {:error,
              %ErrorMessage{
                code: :not_found,
                message: "no records found",
                details: %{params: %{}, query: GraphqlApiRtr.Accounts.User}
              }} ===
               Accounts.find_user(%{})
    end

    test "returns tuple with :error and info when a matching user does not exist", %{
      user: %{id: id}
    } do
      assert Accounts.find_user(%{id: id + 1}) ===
               {:error,
                %ErrorMessage{
                  code: :not_found,
                  details: %{params: %{id: id + 1}, query: GraphqlApiRtr.Accounts.User},
                  message: "no records found"
                }}
    end
  end

  describe "update_user/2" do
    setup :user

    test "updates an existing user", %{user: user} do
      assert [%User{email: "email@example.com"}] = Accounts.all_users(%{})

      assert {:ok, %User{email: "wizard@example.com"}} =
               Accounts.update_user(user.id, %{email: "wizard@example.com"})

      assert [%User{email: "wizard@example.com"}] = Accounts.all_users(%{})
    end

    test "returns the unchanged user when no update params are provided",
         %{user: user} do
      assert {:ok, %User{email: "email@example.com"}} = Accounts.update_user(user.id, %{})
      assert [%User{email: "email@example.com"}] = Accounts.all_users(%{})
    end

    test "returns tuple with :error and map with error info when another user's email is provided",
         %{user: user} do
      assert [%User{email: "email@example.com"}] = Accounts.all_users(%{})
      create_params = Map.put(@valid_user_params, :preferences, @valid_preference_params)

      assert {:ok, %User{id: id, email: user2_email, preferences: %Preference{user_id: id}}} =
               Accounts.create_user(create_params)

      assert {:error, %Ecto.Changeset{} = changeset} =
               Accounts.update_user(user.id, %{email: user2_email})

      assert %{email: ["has already been taken"]} === errors_on(changeset)
    end
  end

  describe "create_user/1" do
    test "creates a new user with preferences" do
      create_params = Map.put(@valid_user_params, :preferences, @valid_preference_params)

      assert {:ok, %User{id: id, preferences: %Preference{user_id: id}}} =
               Accounts.create_user(create_params)

      assert [%User{}] = Repo.all(User)
      assert [%Preference{}] = Repo.all(Preference)
    end

    test "cannot create two users with identical email addresses" do
      create_params = Map.put(@valid_user_params, :preferences, @valid_preference_params)

      assert {:ok, %User{id: id, preferences: %Preference{user_id: id}}} =
               Accounts.create_user(create_params)

      assert {:error, %Ecto.Changeset{} = changeset} = Accounts.create_user(create_params)
      assert %{email: ["has already been taken"]} === errors_on(changeset)
    end
  end

  describe "delete_user/1" do
    setup :user

    test "deletes a user including their preferences", %{user: user} do
      id = user.id
      Accounts.delete_user(user)

      assert Accounts.find_user(%{id: user.id}) ===
               {:error,
                %ErrorMessage{
                  code: :not_found,
                  details: %{params: %{id: id}, query: GraphqlApiRtr.Accounts.User},
                  message: "no records found"
                }}

      assert Accounts.all_preferences() === []
    end
  end

  describe "all_preferences/1" do
    setup :user

    test "returns a list of all preferences when no params are given", %{user: %{id: id}} do
      assert [%Preference{user_id: ^id}] = Accounts.all_preferences()
    end

    test "returns a list of all sets of preferences matching the given parameter(s)", %{
      user: %{id: id}
    } do
      assert [%Preference{user_id: ^id, likes_emails: false}] =
               Accounts.all_preferences(%{likes_emails: false})

      assert [%Preference{user_id: ^id, likes_emails: false, likes_faxes: false}] =
               Accounts.all_preferences(%{likes_emails: false, likes_faxes: false})
    end
  end

  describe "find_preferences/1" do
    setup :user

    test "returns a a tuple with :ok and the corresponding preferences when preferences for a given user ID exist",
         %{
           user: %{id: id}
         } do
      assert {:ok, %Preference{user_id: ^id}} = Accounts.find_preferences(%{user_id: id})
    end

    test "returns tuple with :error and reason when there are no preference for a given user ID",
         %{user: %{id: id}} do
      assert Accounts.find_preferences(%{id: id + 1}) ===
               {:error,
                %ErrorMessage{
                  code: :not_found,
                  details: %{params: %{id: id + 1}, query: GraphqlApiRtr.Accounts.Preference},
                  message: "no records found"
                }}
    end
  end

  describe "update_preferences/2" do
    setup :user

    test "returns updated preferences", %{user: %{id: id}} do
      assert {:ok,
              %Preference{
                user_id: ^id,
                likes_emails: true,
                likes_faxes: false,
                likes_phone_calls: false
              }} = Accounts.update_preferences(id, %{likes_emails: true})

      assert [%Preference{likes_emails: true}] = Accounts.all_preferences()
    end

    test "returns unchanged preferences when no update params are provided",
         %{user: %{id: id}} do
      assert {:ok,
              %Preference{
                user_id: ^id,
                likes_emails: false,
                likes_faxes: false,
                likes_phone_calls: false
              }} = Accounts.update_preferences(id, %{})

      assert [%Preference{likes_emails: false}] = Accounts.all_preferences()
    end
  end
end
