defmodule Flamelex.Fluxus.Radix do
  use GenServer
  require Logger

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def get do
    GenServer.call(__MODULE__, :get_state)
  end

  def init(args) do
    # Use :continue to initialize state after normal GenServer startup
    # this prevents blocking the main app supervision tree's startup
    # since building the radix tree can take a while / might fail
    {:ok, args, {:continue, :initialize}}
  end

  # initialize state, off the main process tree bootup sequence
  def handle_continue(:initialize, args) do
    Logger.debug("#{__MODULE__} starting up...")

    # compute state changes in a task for safety
    case Wormhole.capture(construct_init_radix_state_fn(args), crush_report: true) do
      {:ok, init_radix_state} ->
        subscribe_to_pubsub_topics()
        Logger.debug("#{__MODULE__} started successfully.")
        {:noreply, init_radix_state}

      {:error, reason} ->
        Logger.error("#{__MODULE__} failed to initialize. #{inspect(reason)}")
        {:noreply, :initialization_failure}
    end
  end

  def handle_call(:get_state, _from, state) do
    {:reply, {:ok, state}, state}
  end

  # this function recieves events from the EventBus subscriptions
  def process(event_shadow) do
    # fetch the event in the caller process (I think it's within the sup tree of :event_bus app?)
    # then cast it to the GenServer (itself) so that we have access to rdx_state
    # we need to pass event_shadow all the way through so that we can ack
    # the event at the end of the processing
    e = EventBus.fetch_event(event_shadow)
    GenServer.cast(__MODULE__, {:event, e, event_shadow})
  end

  def handle_cast(_any_msg, :initialization_failure) do
    Logger.warning(
      "#{__MODULE__} is in a failed state of `:initialization_failure`, events are being ignored."
    )

    {:noreply, :initialization_failure}
  end

  def handle_cast({:event, e, e_shadow}, radix_state) do
    case Wormhole.capture(handle_event_fn(radix_state, e, e_shadow), crush_report: true) do
      {:ok, :ignore} ->
        {:noreply, radix_state}

      {:ok, new_radix_state} ->
        Flamelex.Lib.Utils.PubSub.broadcast(
          topic: :radix_state_change,
          msg: {:radix_state_change, new_radix_state}
        )

        {:noreply, new_radix_state}

      {:error, reason} ->
        formatted_error = ~s|\n
        id: #{e.id},
        topic: #{e.topic},
        event: #{inspect(e.data)}
        reason: #{inspect(reason)}
        |

        Logger.error("#{__MODULE__} failed to process event.#{formatted_error}")

        {:noreply, radix_state}
    end
  end

  defp construct_init_radix_state_fn(args) do
    # have to return a zero arity function for Task.async
    fn -> Flamelex.Fluxus.NeoRadixState.new(args) end
  end

  defp handle_event_fn(radix_state, %{topic: topic, data: event}, e_shadow) do
    # have to return a zero arity function for Task.async
    fn ->
      Logger.debug("#{__MODULE__} handling event: #{inspect(event)}, topic: #{inspect(topic)}...")

      handler =
        case topic do
          :flx_actions -> Flamelex.Fluxus.RadixReducer
          :flx_user_input -> Flamelex.Fluxus.UserInputHandler
          :memelex -> Flamelex.Fluxus.MemelexEventHandler
        end

      case handler.process(radix_state, event) do
        :ignore ->
          EventBus.mark_as_completed({__MODULE__, e_shadow})
          :ignore

        ^radix_state ->
          EventBus.mark_as_completed({__MODULE__, e_shadow})
          :ignore

        new_radix_state ->
          EventBus.mark_as_completed({__MODULE__, e_shadow})
          new_radix_state
      end
    end
  end

  defp subscribe_to_pubsub_topics do
    EventBus.subscribe(
      {__MODULE__,
       [
         to_string(:flx_actions),
         to_string(:memelex),
         to_string(:flx_user_input)
       ]}
    )
  end
end
