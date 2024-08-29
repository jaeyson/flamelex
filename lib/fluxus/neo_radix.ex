defmodule Flamelex.Fluxus.Radix do
  use GenServer
  require Logger

  import Flamelex.Fluxus.Utils, only: [do_task: 1]

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
    case do_task(construct_new_radix_state(args)) do
      {:ok, state} ->
        subscribe_to_pubsub_topics()
        Logger.debug("#{__MODULE__} started successfully.")
        {:noreply, state}

      {:error, _reason} ->
        Logger.error("#{__MODULE__} failed to initialize.")
        {:noreply, :initialization_failure}
    end
  end

  def handle_call(:get_state, _from, state) do
    {:reply, {:ok, state}, state}
  end

  # def handle_cast({:flx_user_input, ii}, state) do
  #   Logger.debug("#{__MODULE__} handling user input... #{inspect(ii)}")
  #   # TODO really handle the user input here
  #   {:noreply, state}
  # end

  # this function recieves events from the EventBus subscriptions
  def process(event_shadow) do
    GenServer.cast(__MODULE__, {:event, event_shadow})
  end

  def handle_cast({:event, event_shadow}, state) do
    %{data: event} = EventBus.fetch_event(event_shadow)

    case handle_event(state, event) do
      {:ok, new_state} ->
        EventBus.mark_as_completed({__MODULE__, event_shadow})
        {:noreply, new_state}

      {:error, _reason} ->
        EventBus.mark_as_completed({__MODULE__, event_shadow})
        {:noreply, state}
    end
  end

  def handle_event(state, {:user_input, ii}) do
    Logger.debug("#{__MODULE__} handling user input... #{inspect(ii)}")
    # TODO really handle the user input here

    #   case Flamelex.Fluxus.UserInputHandler.process(radix_state, input) do
    #     :ignore ->
    #       # Logger.debug "#{__MODULE__} ignoring... #{inspect(%{radix_state: radix_state, action: action})}"
    #       EventBus.mark_as_completed({__MODULE__, event_shadow})

    #     {:ok, ^radix_state} ->
    #       # Logger.debug "#{__MODULE__} ignoring (no state-change)..."
    #       EventBus.mark_as_completed({__MODULE__, event_shadow})

    #     {:ok, new_radix_state} ->
    #       # Logger.debug "#{__MODULE__} processed event, state changed..."
    #       Flamelex.Fluxus.RadixStore.put(new_radix_state)
    #       EventBus.mark_as_completed({__MODULE__, event_shadow})
    #   end

    {:ok, state}
  end

  # event handler for user input
  # def process({@user_input, _id} = event_shadow) do
  #   %EventBus.Model.Event{data: {:input, input}} = EventBus.fetch_event(event_shadow)

  #   # TODO lock the store? even better, just make it a GenServer - pass the input handler function in & run it in the context of the Store process
  #   radix_state = Flamelex.Fluxus.RadixStore.get()

  #   case Flamelex.Fluxus.UserInputHandler.process(radix_state, input) do
  #     :ignore ->
  #       # Logger.debug "#{__MODULE__} ignoring... #{inspect(%{radix_state: radix_state, action: action})}"
  #       EventBus.mark_as_completed({__MODULE__, event_shadow})

  #     {:ok, ^radix_state} ->
  #       # Logger.debug "#{__MODULE__} ignoring (no state-change)..."
  #       EventBus.mark_as_completed({__MODULE__, event_shadow})

  #     {:ok, new_radix_state} ->
  #       # Logger.debug "#{__MODULE__} processed event, state changed..."
  #       Flamelex.Fluxus.RadixStore.put(new_radix_state)
  #       EventBus.mark_as_completed({__MODULE__, event_shadow})
  #   end
  # end

  # construct a new radix state
  defp construct_new_radix_state(args) do
    # have to return a zero arity function for Task.async
    fn -> Flamelex.Fluxus.NeoRadixState.new(args) end
  end

  @actions to_string(:flx_actions)
  @memelex to_string(:memelex)
  @user_input to_string(:flx_user_input)
  defp subscribe_to_pubsub_topics do
    EventBus.subscribe({__MODULE__, [@actions]})
    EventBus.subscribe({__MODULE__, [@memelex]})
    EventBus.subscribe({__MODULE__, [@user_input]})
    :ok
  end

  # # this function offloads work to an asynchronous task
  # # and returns that result or an error if the task fails
  # @task_timeout :timer.seconds(3)
  # defp do_task(task_fn) when is_function(task_fn, 0) do
  #   task = Task.async(task_fn)
  #   result = Task.yield(task, @task_timeout) || Task.shutdown(task, :brutal_kill)

  #   case result do
  #     {:ok, task_result} ->
  #       # Task completed successfully
  #       {:ok, task_result}

  #     nil ->
  #       # Task timed out
  #       {:error, :timeout}

  #     {:exit, _reason} ->
  #       # Task crashed or exited with an error
  #       {:error, :task_failed}
  #   end
  # end
end
