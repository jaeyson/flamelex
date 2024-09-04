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
    fn -> Flamelex.Fluxus.RadixState.new(args) end
  end

  defp handle_event_fn(radix_state, %{topic: topic, data: event}, e_shadow) do
    # have to return a zero arity function for Task.async
    fn ->
      # Logger.debug("#{__MODULE__} handling event: #{inspect(event)}, topic: #{inspect(topic)}...")

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

# defmodule Flamelex.Fluxus.RadixStore do
#   @moduledoc """
#   This module just stores the actual state itself - modifications are
#   made elsewhere.

#   https://www.bounga.org/elixir/2020/02/29/genserver-supervision-tree-and-state-recovery-after-crash/

#   The GUI.Component and the Buffer.Component have a shared state, via an
#   Agent process. They receive an action, they go fetch the state, they
#   can lock it if needed (call), and they can process it. If the state changes,
#   then act of changing it can publish a msg to other listeners (i.e. the
#   GUI.Component) who will have to re-render their shit.

#   Although I did try it, I decided not to go with using the event-bus for
#   updating the GUI due to a state change. The event-bus serves it's purpose
#   by funneling all action through one choke-point, and keeps track of
#   them etc, but just pushing updates to the GUI is simpler when done via
#   a PubSub (no need to acknowledge events as complete), and easier to
#   implement, since the EventBus lib we're using receives events in a
#   separate process to the one where we actually declared the function.
#   We could forward the state updates on to each ScenicComponent, but then
#   we start to have problems of how to handle addressing... the exact problem
#   that PubSub is a perfect solution for.
#   """
#   use Agent
#   require Logger

#   # TODO make this a GenServer & do all edits in the context of the GenServer

#   def start_link(radix_state) do
#     # radix_state = Flamelex.Fluxus.Structs.RadixState.initialize()
#     Agent.start_link(fn -> radix_state end, name: RadixStore)
#   end

#   def get do
#     Agent.get(RadixStore, & &1)
#   end

#   # NOTE: Here we update, but don't broadcast the changes. For example,
#   #      adding user-input to the input history, doesn't need to be broadcast.
#   def put(new_state) do
#     # Logger.debug("#{RadixStore} updating state...")
#     Agent.update(RadixStore, fn _old -> new_state end)
#   end

#   def put_viewport(%Scenic.ViewPort{} = new_vp) do
#     Agent.update(RadixStore, fn radix_state ->
#       radix_state |> put_in([:gui, :viewport], new_vp)
#     end)
#   end

#   # #NOTE: When `Flamelex.GUI.RootScene` boots, it calls this function.
#   # #      We don't want to broadcast these changes out.
#   # def put_root_graph(new_graph) do
#   #   Agent.update(RadixStore, fn radix_state ->
#   #     radix_state
#   #     |> put_in([:root, :graph], new_graph)
#   #   end)
#   # end

#   # update/1 also broadcasts changes to the rest of the app
#   def update(new_state) do
#     # Logger.debug("#{RadixStore} updating state & broadcasting new_state...")
#     # Logger.debug("#{RadixStore} updating state & broadcasting new_state: #{inspect(new_state)}")

#     Flamelex.Lib.Utils.PubSub.broadcast(
#       topic: :radix_state_change,
#       msg: {:radix_state_change, new_state}
#     )

#     Agent.update(RadixStore, fn _old -> new_state end)
#   end

#   def update_viewport(%Scenic.ViewPort{} = new_vp) do
#     Agent.update(RadixStore, fn radix_state ->
#       new_radix_state = radix_state |> put_in([:gui, :viewport], new_vp)

#       Flamelex.Lib.Utils.PubSub.broadcast(
#         topic: :radix_state_change,
#         msg: {:radix_state_change, new_radix_state}
#       )

#       new_radix_state
#     end)
#   end
# end

# # defmodule Flamelex.Fluxus.MemexStore do
# #   use Agent
# #   require Logger
# #   @moduledoc """
# #   This module just stores the actual state itself - modifications are
# #   made elsewhere.

# #   https://www.bounga.org/elixir/2020/02/29/genserver-supervision-tree-and-state-recovery-after-crash/

# #   All the state for the app is stored in this process. GUI.Components receive
# #   an action, they go fetch the state, they can lock it if needed (call), and
# #   they can process it.  If the state changes, then act of changing it can
# #   publish a msg to other listeners (i.e. the GUI.Component) who will have to
# #   re-render themselves.

# #   Although I did try it, I decided not to go with using the event-bus for
# #   updating the GUI due to a state change. The event-bus serves it's purpose
# #   by funneling all action through one choke-point, and keeps track of
# #   them etc, but just pushing updates to the GUI is simpler when done via
# #   a PubSub (no need to acknowledge events as complete), and easier to
# #   implement, since the EventBus lib we're using receives events in a
# #   separate process to the one where we actually declared the function.
# #   We could forward the state updates on to each ScenicComponent, but then
# #   we start to have problems of how to handle addressing... the exact problem
# #   that PubSub is a perfect solution for.
# #   """

# #   #TODO make this a GenServer & do all edits in the context of the GenServer
# #   #TODO this should be a GenServer so we dont copy the state out & manipulate it in another process

# #   def start_link(_params) do
# #     radix_state = Memelex.Fluxus.Structs.RadixState.init()
# #     Agent.start_link(fn -> radix_state end, name: __MODULE__)
# #   end

# #   def get do
# #     Agent.get(__MODULE__, & &1)
# #   end

# #   #NOTE: Here we update, but don't broadcast the changes. For example,
# #   #      adding user-input to the input history, doesn't need to be broadcast.
# #   def put(new_state) do
# #     #Logger.debug("#{RadixStore} updating state...")
# #     Agent.update(__MODULE__, fn _old -> new_state end)
# #   end

# #   def put_viewport(%Scenic.ViewPort{} = new_vp) do
# #     Agent.update(__MODULE__, fn radix_state ->
# #       radix_state |> put_in([:gui, :viewport], new_vp)
# #     end)
# #   end

# #   #NOTE: When `Flamelex.GUI.RootScene` boots, it calls this function.
# #   #      We don't want to broadcast these changes out.
# #   # def put_root_graph(new_graph) do
# #   #   Agent.update(RadixStore, fn radix_state ->
# #   #     radix_state
# #   #     |> put_in([:root, :graph], new_graph)
# #   #   end)
# #   # end

# #   # update/1 also broadcasts changes to the rest of the app
# #   def update(new_state) do
# #     #Logger.debug("#{RadixStore} updating state & broadcasting new_state...")
# #     #Logger.debug("#{RadixStore} updating state & broadcasting new_state: #{inspect(new_state)}")

# #     Memelex.Utils.PubSub.broadcast({:radix_state_change, new_state})
# #         #TODO dont use `radix_state_cjhange` any more

# #     Agent.update(__MODULE__, fn _old -> new_state end)
# #   end

# #   def update_viewport(%Scenic.ViewPort{} = new_vp) do
# #     Agent.update(__MODULE__, fn radix_state ->

# #       new_radix_state =
# #         radix_state |> put_in([:gui, :viewport], new_vp)

# #       Memelex.Utils.PubSub.broadcast(
# #         {:radix_state_change, new_radix_state})

# #       new_radix_state
# #     end)
# #   end
# # end
