defmodule GraphqlApiRtr.Metrics.AuthToken do
  import Telemetry.Metrics, only: [counter: 2, distribution: 2]

  def metrics do
    [
      counter(
        "auth_token_generation_count",
        event_name: [:graphql_api_rtr, :metrics, :auth_token, :generation_count],
        description: "Total number of auth tokens generated"
      ),
      distribution(
        "auth_token_generation_duration_seconds",
        event_name: [:graphql_api_rtr, :metrics, :auth_token, :generation_duration],
        measurement: :duration,
        unit: {:native, :second},
        reporter_options: [
          buckets: [0.01, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5]
        ],
        description: "Time taken to generate auth tokens"
      )
    ]
  end

  def inc_to_save do
    :telemetry.execute([:event_namespace, :my_metric], %{count: 1})
  end

  def set_custom_name do
    :telemetry.execute([:event_namespace, :last_value], %{total: 123}, %{custom_metric: "region"})
  end
end
