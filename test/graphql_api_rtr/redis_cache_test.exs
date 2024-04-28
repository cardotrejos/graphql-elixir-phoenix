defmodule GraphqlApiRtr.RedisCacheTest do
  use ExUnit.Case

  setup_all do
    # Stop the GraphqlApiRtr.RedisCache process if it's already running
    if Process.whereis(GraphqlApiRtr.RedisCache) do
      GenServer.stop(GraphqlApiRtr.RedisCache)
    end

    # Start the GraphqlApiRtr.RedisCache process for testing
    start_supervised!(GraphqlApiRtr.RedisCache)
    :ok
  end

  describe "get/1" do
    test "returns nil when key does not exist" do
      assert GraphqlApiRtr.RedisCache.get("nonexistent_key") == nil
    end

    test "returns the cached value when key exists" do
      key = "test_key"
      value = %{foo: "bar"}
      GraphqlApiRtr.RedisCache.put(key, 3600, value)
      assert GraphqlApiRtr.RedisCache.get(key) == value
    end
  end

  describe "put/3" do
    test "stores the value in cache with the specified TTL" do
      key = "test_key"
      value = %{foo: "bar"}
      ttl = 3600
      GraphqlApiRtr.RedisCache.put(key, ttl, value)
      assert GraphqlApiRtr.RedisCache.get(key) == value
    end
  end
end
