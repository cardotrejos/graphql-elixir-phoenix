defmodule GraphqlApiRtrWeb.Resolvers.User do
  @moduledoc false
  alias GraphqlApiRtr.{Accounts, HitCounter}

  def all(params, _) do
    HitCounter.add_hit(:users)
    {:ok, Accounts.all_users(params)}
  end

  def find(params, _) do
    HitCounter.add_hit(:user)
    Accounts.find_user(params)
  end

  def create_user(params, _) do
    HitCounter.add_hit(:create_user)
    Accounts.create_user(params)
  end

  def update_user(%{id: id} = params, _) do
    HitCounter.add_hit(:update_user)
    :counters.add(:persistent_term.get(:hit_counter), 8, 1)

    id
    |> String.to_integer()
    |> Accounts.update_user(Map.delete(params, :id))
  end
end
