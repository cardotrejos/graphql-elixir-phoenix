defmodule GraphqlApiRtr.HitCounter do
  @moduledoc """
  Distributed request counter using a CRDT cache.

  We chose to use a CRDT cache for the following reasons:
  - CRDTs provide eventual consistency, which is suitable for a distributed counter.
  - CRDTs are partition-tolerant and highly available, allowing the counter to work across multiple nodes.
  - CRDTs can merge updates from different nodes, ensuring that the counter values converge over time.
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
    # Initialize the CRDT counter
    :persistent_term.put(:hit_counter, :counters.new(Enum.count(@indexes), [:write_concurrency]))
  end

  def add_hit(request) when request in @request_types do
    # Increment the counter locally
    :counters.add(hit_counter(), index(request), 1)
    # Broadcast the update to other nodes
    :rpc.abcast(Node.list(), __MODULE__, {:merge_hit, request})
  end

  def merge_hit(request) do
    # Merge the received update with the local counter
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

# defmodule GraphqlApiRtr.HitCounter do
#   @moduledoc """
#   Distributed request counter using a Singleton Cache.

#   One node is selected as the cache holder based on a consistent hash of the node names.
#   Other nodes retrieve the counter values from the cache holder node.
#   """

#   def setup_counter do
#     if is_cache_holder?() do
#       :persistent_term.put(:hit_counter, :counters.new(Enum.count(@indexes), [:write_concurrency]))
#     end
#   end

#   def add_hit(request) when request in @request_types do
#     if is_cache_holder?() do
#       :counters.add(hit_counter(), index(request), 1)
#     else
#       :rpc.call(cache_holder_node(), __MODULE__, :add_hit, [request])
#     end
#   end

#   def get_hits(request) when request in @request_types do
#     if is_cache_holder?() do
#       :counters.get(hit_counter(), index(request))
#     else
#       :rpc.call(cache_holder_node(), __MODULE__, :get_hits, [request])
#     end
#   end

#   defp is_cache_holder?() do
#     node() == cache_holder_node()
#   end

#   defp cache_holder_node() do
#     nodes = [node() | Node.list()]
#     Enum.min_by(nodes, &:erlang.phash2/1)
#   end
# end
