defmodule GraphqlApiRtr.Metrics.CacheMetrics do
  import Telemetry.Metrics, only: [counter: 2, distribution: 2]

  def metrics do
    [
      counter(
        "cache_get_count",
        event_name: [:my_app, :cache, :get],
        description: "Total number of cache get operations"
      ),
      distribution(
        "cache_get_duration_seconds",
        event_name: [:my_app, :cache, :get],
        measurement: :duration,
        unit: {:native, :second},
        reporter_options: [
          buckets: [0.01, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5]
        ],
        description: "Time taken for cache get operations"
      ),
      counter(
        "cache_put_count",
        event_name: [:my_app, :cache, :put],
        description: "Total number of cache put operations"
      ),
      distribution(
        "cache_put_duration_seconds",
        event_name: [:my_app, :cache, :put],
        measurement: :duration,
        unit: {:native, :second},
        reporter_options: [
          buckets: [0.01, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5]
        ],
        description: "Time taken for cache put operations"
      ),
    ]
  end

  def setup do
    :telemetry.attach_many(
      "cache_metrics",
      [
        [:my_app, :cache, :get],
        [:my_app, :cache, :put],
        [:my_app, :cache, :size]
      ],
      &handle_event/4,
      nil
    )
  end

  def handle_event([:my_app, :cache, :get], %{duration: duration}, metadata, _config) do
    :telemetry.execute([:my_app, :cache, :get], %{duration: duration}, metadata)
  end

  def handle_event([:my_app, :cache, :put], %{duration: duration}, metadata, _config) do
    :telemetry.execute([:my_app, :cache, :put], %{duration: duration}, metadata)
  end

  def handle_event([:my_app, :cache, :size], %{size: size}, metadata, _config) do
    :telemetry.execute([:my_app, :cache, :size], %{size: size}, metadata)
  end
end
