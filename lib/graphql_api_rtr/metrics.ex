defmodule GraphqlApiRtr.Metrics do
  def metrics do
    [
      # Other metrics...
      GraphqlApiRtr.Metrics.AuthToken.metrics()
    ]
  end
end
