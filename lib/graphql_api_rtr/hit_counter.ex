defmodule GraphqlApiRtr.HitCounter do
  @moduledoc """
  Starts up the counter and stores it as a persistent term
  """

  @request_types [
    :preferences,
    :user_preferences,
    :users,
    :user,
    :resolver_hits,
    :update_user_preferences,
    :create_user,
    :update_user,
    :auth_token,
    :test_request
  ]

  @indexes [
    :preferences,
    :update_user_preferences,
    :user_preferences,
    :resolver_hits,
    :users,
    :user,
    :create_user,
    :update_user,
    :auth_token,
    :test_request
  ]

  def setup_counter do
    hit_counter = :counters.new(Enum.count(@indexes), [:write_concurrency])
    :persistent_term.put(:hit_counter, hit_counter)
  end

  def add_hit(request) when request in @request_types do
    :counters.add(hit_counter(), index(request), 1)
  end

  def get_hits(request) when request in @request_types do
    nodes = [node() | Node.list()]

    Enum.reduce(nodes, 0, fn x, acc ->
      acc + :erpc.call(x, __MODULE__, :get_cluster_hits, [request])
    end)
  end

  def get_cluster_hits(request) do
    :counters.get(hit_counter(), index(request))
  end

  def request_types, do: @request_types

  defp hit_counter do
    :persistent_term.get(:hit_counter)
  end

  defp index(request) do
    Enum.find_index(@indexes, &(&1 === request)) + 1
  end
end
