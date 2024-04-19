defmodule GraphqlApiRtr.Pipeline.ConsumerSupervisor do
  @moduledoc false
  use ConsumerSupervisor

  def start_link(caller) when is_pid(caller) do
    ConsumerSupervisor.start_link(__MODULE__, caller)
  end

  @impl ConsumerSupervisor
  def init(caller) when is_pid(caller) do
    children = [
      %{
        id: GraphqlApiRtr.Pipeline.Consumer,
        start: {GraphqlApiRtr.Pipeline.Consumer, :start_link, [caller]},
        restart: :transient
      }
    ]

    opts = [
      strategy: :one_for_one,
      subscribe_to: [
        GraphqlApiRtr.Pipeline.Producer
      ]
    ]

    ConsumerSupervisor.init(children, opts)
  end
end
