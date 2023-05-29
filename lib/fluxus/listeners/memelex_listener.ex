defmodule Flamelex.Fluxus.MemelexListener do
  @moduledoc """
  This process listens to events on the :memelex topic, which exists
  inside the Memelex app.
  """
  use GenServer
  require Logger

  @topic :memelex

  def start_link(_args) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(_args) do
    EventBus.subscribe({__MODULE__, ["memelex"]})
    {:ok, %{}}
  end

  def process({@topic, _id} = event_shadow) do
    event = EventBus.fetch_event(event_shadow)

    %EventBus.Model.Event{id: _id, topic: @topic, data: memelex_event} = event

    # TODO lock the store?
    radix_state = Flamelex.Fluxus.RadixStore.get()

    # TODO this is I think one of the sources of our errors, because we dont truly process events in sequence because a second event can come in while another event is processing

    # but then again, events shouldnt get picked up till the last one finishes??
    # event1 arrives, gets copy (but doesnt lock) the store, begins processing (this processing will *eventually* mutate the store)
    # event2 arrives, gets copy of the store (same as what event1 has)
    #

    case Flamelex.Fluxus.MemelexEventHandler.process(radix_state, memelex_event) do
      :ignore ->
        # try_custom_input_handler(radix_state, input, event_shadow)

        # Logger.debug "#{__MODULE__} ignoring... #{inspect(%{radix_state: radix_state, action: action})}"
        EventBus.mark_as_completed({__MODULE__, event_shadow})

      {:ok, ^radix_state} ->
        # Logger.debug "#{__MODULE__} ignoring (no state-change)..."
        EventBus.mark_as_completed({__MODULE__, event_shadow})

      {:ok, new_radix_state} ->
        # Logger.debug "#{__MODULE__} processed event, state changed..."
        Flamelex.Fluxus.RadixStore.put(new_radix_state)
        EventBus.mark_as_completed({__MODULE__, event_shadow})
    end
  end
end
