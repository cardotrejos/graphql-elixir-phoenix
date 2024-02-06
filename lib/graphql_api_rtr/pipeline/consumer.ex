defmodule GraphqlApiRtr.Pipeline.Consumer do
  @moduledoc """
  Checks if user's auth token is expired and if so, updates the auth token
  """

  alias GraphqlApiRtr.{Pipeline.Helpers, TokenCache}

  @spec start_link(pid, non_neg_integer()) :: {:ok, pid}
  def start_link(caller, user_id) do
    Task.start_link(fn ->
      handle_event(caller, user_id)
    end)
  end

  defp handle_event(caller, user_id) do
    if Helpers.update_needed?(user_id) === true do
      TokenCache.put(user_id, Helpers.token_and_timestamp_map())
    end

    Helpers.maybe_send_sync(caller)
  end
end
