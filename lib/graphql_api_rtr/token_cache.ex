defmodule GraphqlApiRtr.TokenCache do
  @moduledoc false
  use Task, restart: :permanent

  @table_name :token_cache
  @ets_opts [
    :named_table,
    :public,
    :compressed,
    write_concurrency: true,
    read_concurrency: true
  ]

  def start_link(_opts \\ []) do
    Task.start_link(fn ->
      _ = :ets.new(@table_name, @ets_opts)

      Process.hibernate(Function, :identity, [])
    end)
  end

  def put(key, value) do
    :ets.insert(@table_name, {key, value})

    auth_token = Map.merge(value, %{user_id: key})

    Absinthe.Subscription.publish(GraphqlApiRtrWeb.Endpoint, auth_token,
      auth_token_generated: "user_auth_token_generated:#{key}"
    )
  end

  def get(key) do
    case :ets.lookup(@table_name, key) do
      [] -> nil
      [{^key, value}] -> value
    end
  end
end
