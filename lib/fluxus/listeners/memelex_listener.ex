# defmodule Flamelex.Fluxus.MemelexListener do
#   @moduledoc """
#   This process listens to events on the :memelex topic, which exists
#   inside the Memelex app. This is where we process Memelex events, and
#   thus this is how we can use IEx (via Memelex) to cause changes in
#   the Flkamelex state & GUI.
#   """
#   use GenServer
#   require Logger

#   @topic :memelex

#   def start_link(_args) do
#     GenServer.start_link(__MODULE__, [], name: __MODULE__)
#   end

#   def init(_args) do
#     EventBus.subscribe({__MODULE__, [to_string(@topic)]})
#     {:ok, %{}}
#   end

#   def process({@topic, _id} = event_shadow) do
#     event = EventBus.fetch_event(event_shadow)

#     # %EventBus.Model.Event{topic: @topic, data: event} = event

#     # TODO lock the store? Answer - all mutations ought to occure in the radix_store process (or rather, that process uses tasks, but in effect it's that process)
#     radix_state = Flamelex.Fluxus.RadixStore.get()
#     # memex_state = Flamelex.Fluxus.MemexStore.get()
#     # I guess for Memex we have 2 stores?? I think I went away from this after a while...

#     # TODO this is I think one of the sources of our errors, because we dont truly process events in sequence because a second event can come in while another event is processing

#     # but then again, events shouldnt get picked up till the last one finishes??
#     # event1 arrives, gets copy (but doesnt lock) the store, begins processing (this processing will *eventually* mutate the store)
#     # event2 arrives, gets copy of the store (same as what event1 has)
#     #

#     case Flamelex.Fluxus.MemelexEventHandler.process(radix_state, event.data) do
#       x when x in [:ignore, :ok] ->
#         EventBus.mark_as_completed({__MODULE__, event_shadow})
#         # Logger.debug "#{__MODULE__} ignoring... #{inspect(%{action: action})}"
#         # Logger.debug "#{__MODULE__} ignoring... #{inspect(%{radix_state: radix_state, action: action})}"
#         :ignore

#       {:ok, ^radix_state} ->
#         # radix_state didnt change, so we dont need to update the store
#         EventBus.mark_as_completed({__MODULE__, event_shadow})

#         # Logger.debug "#{__MODULE__} ignoring (no state-change)... #{inspect(%{radix_state: radix_state, action: action})}"
#         # Logger.debug "#{__MODULE__} ignoring (no state-change)..."
#         :ignore

#       {:ok, new_radix_state} ->
#         # Logger.debug "#{__MODULE__} processed event, state changed..."
#         # Logger.debug "#{__MODULE__} processed event, state changed... #{inspect(%{radix_state: radix_state, action: action})}"
#         Flamelex.Fluxus.RadixStore.update(new_radix_state)
#         EventBus.mark_as_completed({__MODULE__, event_shadow})
#         {:ok, new_radix_state}

#       {:error, reason} ->
#         Logger.error("Unable to process event: #{inspect(reason)}")
#         # EventBus.mark_as_completed({__MODULE__, event_shadow})
#         raise reason
#     end

#     # EventBus.mark_as_completed({__MODULE__, event_shadow})
#   end
# end
