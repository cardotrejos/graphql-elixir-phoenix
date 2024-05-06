defmodule GraphqlApiRtr.RedisCacheTest do
  use ExUnit.Case

  alias GraphqlApiRtr.RedisCache

  # Setup block for each test to ensure isolated environment
  setup do
    # Start a new RedisCache process for each test to ensure isolation
    {:ok, pid} = RedisCache.start_link(redis_opts: [host: "localhost"])
    {:ok, pid: pid}
  end

  describe "get/2" do
    test "returns nil when key does not exist", %{pid: pid} do
      assert RedisCache.get(pid, "nonexistent_key") == nil
    end

    test "returns the cached value when key exists", %{pid: pid} do
      key = "test_key"
      value = "bar"
      RedisCache.put(pid, key, 3600, value)
      assert RedisCache.get(pid, key) == value
    end
  end

  describe "put/4" do
    test "stores the value in cache with the specified TTL", %{pid: pid} do
      key = "test_key"
      value = "bar"
      ttl = 3600
      RedisCache.put(pid, key, ttl, value)
      assert RedisCache.get(pid, key) == value
    end
  end
end
