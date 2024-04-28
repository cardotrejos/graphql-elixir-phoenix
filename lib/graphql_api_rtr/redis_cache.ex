defmodule GraphqlApiRtr.RedisCache do
  require Logger
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  @impl true
  def init(opts) do
    redis_opts = Application.get_env(:graphql_api_rtr, __MODULE__)
    {:ok, conn} = Redix.start_link(redis_opts)
    {:ok, %{conn: conn}}
  end

  def get(key) do
    start_time = System.monotonic_time()
    result = case Redix.command(conn(), ["GET", key]) do
      {:ok, nil} -> nil
      {:ok, value} -> :erlang.binary_to_term(value)
    end
    duration = System.monotonic_time() - start_time
    :telemetry.execute([:my_app, :cache, :get], %{duration: duration}, %{key: key})
    result
  end

  def put(key, ttl, value) do
    start_time = System.monotonic_time()
    result = Redix.command(conn(), ["SETEX", key, ttl, :erlang.term_to_binary(value)])
    duration = System.monotonic_time() - start_time
    :telemetry.execute([:my_app, :cache, :put], %{duration: duration}, %{key: key})
    result
  end

  defp conn do
    GenServer.call(__MODULE__, :get_conn)
  end

  @impl true
  def handle_call(:get_conn, _from, state) do
    {:reply, state.conn, state}
  end
end
