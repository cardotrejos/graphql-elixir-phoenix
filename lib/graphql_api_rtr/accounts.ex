defmodule GraphqlApiRtr.Accounts do
  alias GraphqlApiRtr.{Accounts.Preference, Accounts.User, Repo}
  alias EctoShorts.Actions

  @preference_params Preference.required_params()

   def all_users(params, caller \\ self()) do
    user_params = Map.drop(params, @preference_params)

    params
    |> Map.take(@preference_params)
    |> Enum.reduce(User.join_preferences(), fn
      filter, acc -> User.by_preferences(acc, filter)
    end)
    |> Actions.all(user_params, caller: caller)
  end

  def find_user(params) do
    Actions.find(User, params)
  end

  def update_user(id, params) do
    with {:ok, user} <- find_user(%{id: id}) do
      user
      |> Repo.preload(:preferences)
      |> then(&Actions.update(User, &1, params))
    end
  end

  def create_user(params) do
    Actions.create(User, params)
  end

  def delete_user(%User{} = user) do
    Actions.delete(user)
  end

  def all_preferences(params \\ %{}) do
    Actions.all(Preference, params)
  end

  def update_preferences(user_id, params) do
    Actions.find_and_update(Preference, %{user_id: user_id}, params)
  end

  def find_preferences(params) do
    Actions.find(Preference, params)
  end
end
