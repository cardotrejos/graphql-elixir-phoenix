defmodule GraphqlApiRtrWeb.Resolvers.Preference do
  @moduledoc false
  alias GraphqlApiRtr.{Accounts, HitCounter}

  def all(params, _) do
    HitCounter.add_hit(:preferences)

    {:ok, Accounts.all_preferences(params)}
  end

  @spec update_user_preferences(%{:user_id => any, optional(any) => any}, any) ::
          {:error, any} | {:ok, %{optional(atom) => any}}
  def update_user_preferences(%{user_id: user_id} = params, _) do
    HitCounter.add_hit(:update_user_preferences)
    :counters.add(:persistent_term.get(:hit_counter), 2, 1)
    Accounts.update_preferences(user_id, params)
  end

  def find_user_preferences(%{user_id: id}, _) do
    HitCounter.add_hit(:user_preferences)
    Accounts.find_preferences(%{user_id: id})
  end
end
