defmodule GraphqlApiRtr.Pipeline.Producer do
  use GenStage

  @moduledoc """
  Scrapes the database to fulfill the consumer's demand.
  Keeps track (in its state) of any existing demand and available events
  to ensure continuance of the pipeline
  """

  alias GraphqlApiRtr.{Accounts, Config}

  @sleep Config.producer_sleep_time()

  def start_link(caller) when is_pid(caller) do
    GenStage.start_link(__MODULE__, caller, name: __MODULE__)
  end

  @impl GenStage
  def init(caller) when is_pid(caller) do
    Process.send(self(), :scrape, [])
    {:producer, %{demand: 0, events: [], caller: caller}}
  end

  @impl GenStage
  def handle_demand(new_demand, %{demand: demand, events: events, caller: caller}) do
    demand = demand + new_demand
    {outgoing_events, state} = update_state(demand, events, caller)

    {:noreply, outgoing_events, state}
  end

  @impl GenStage
  def handle_info(:scrape, %{demand: demand, events: [], caller: caller}) do
    events =
      %{}
      |> Accounts.all_users(caller)
      |> Enum.map(& &1.id)

    {outgoing_events, state} = update_state(demand, events, caller)

    Process.send_after(self(), :scrape, @sleep)

    {:noreply, outgoing_events, state}
  end

  @impl GenStage
  def handle_info(:scrape, %{demand: demand, events: events, caller: caller}) do
    {outgoing_events, state} = update_state(demand, events, caller)

    Process.send_after(self(), :scrape, @sleep)

    {:noreply, outgoing_events, state}
  end

  defp update_state(demand, events, caller) do
    {outgoing_events, remaining_events} = Enum.split(events, demand)
    demand = demand - Enum.count(outgoing_events)
    state = %{demand: demand, events: remaining_events, caller: caller}
    {outgoing_events, state}
  end
end
