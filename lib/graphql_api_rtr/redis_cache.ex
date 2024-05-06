defmodule GraphqlApiRtr.RedisCache do
  use GenServer
  require Logger

  # Starts the GenServer with Redis connection
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  # GenServer callback to initialize the state
  @impl true
  def init(opts) do
    redis_opts = opts[:redis_opts] || Application.get_env(:graphql_api_rtr, __MODULE__)

    case Redix.start_link(redis_opts) do
      {:ok, conn} ->
        {:ok, %{conn: conn}}

      {:error, _reason} ->
        {:stop, :failed_to_connect}
    end
  end

  # Public API to set a value
  def set(pid, key, value) do
    GenServer.call(pid, {:set, key, value})
  end

  # Public API to get a value
  def get(pid, key) do
    GenServer.call(pid, {:get, key})
  end

  # Public API to put a value with TTL
  def put(pid, key, ttl, value) do
    GenServer.call(pid, {:put, key, ttl, value})
  end

  # Server-side handling of set command
  @impl true
  def handle_call({:set, key, value}, _from, state) do
    start_time = System.monotonic_time()
    result = Redix.command(state.conn, ["SET", key, value])
    duration = System.monotonic_time() - start_time
    :telemetry.execute([:graphql_api_rtr, :cache, :put], %{duration: duration / 1_000_000}, %{key: key})
    {:reply, result, state}
  end

  @impl true
  def handle_call({:get, key}, _from, state) do
    start_time = System.monotonic_time()
    result = handle_redis_get(state.conn, key)
    duration = System.monotonic_time() - start_time
    :telemetry.execute([:graphql_api_rtr, :cache, :get], %{duration: duration / 1_000_000}, %{key: key})
    {:reply, result, state}
  end

  @impl true
  def handle_call({:put, key, ttl, value}, _from, state) do
    start_time = System.monotonic_time()
    result = Redix.command(state.conn, ["SET", key, value, "EX", ttl])
    duration = System.monotonic_time() - start_time
    :telemetry.execute([:graphql_api_rtr, :cache, :put], %{duration: duration / 1_000_000}, %{key: key})
    {:reply, result, state}
  end

  defp handle_redis_get(conn, key) do
    case Redix.command(conn, ["GET", key]) do
      {:ok, nil} ->
        nil

      {:ok, value} ->
        value

      {:error, reason} ->
        Logger.error("Failed to get key #{key} from Redis: #{inspect(reason)}")
        nil
    end
  end
end
