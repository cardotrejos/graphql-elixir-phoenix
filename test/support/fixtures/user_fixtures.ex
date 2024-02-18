defmodule GraphqlApiRtr.UserFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `GraphqlApiRtr.Accounts` context.
  """
  alias GraphqlApiRtr.{Accounts, TokenCache}

  @valid_user_params %{name: "Harry", email: "email@example.com"}

  @valid_preference_params %{likes_emails: false, likes_phone_calls: false, likes_faxes: false}

  def user(_context) do
    {:ok, user} =
      @valid_user_params
      |> Map.put(:preferences, @valid_preference_params)
      |> Accounts.create_user()

    %{user: user}
  end

  def cache_entry(%{user: %{id: id}}) do
    cache_entry = TokenCache.put(id, %{token: "FakeToken", timestamp: DateTime.utc_now()})
    %{cache_entry: cache_entry}
  end

end
