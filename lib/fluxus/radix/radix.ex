defmodule Flamelex.Fluxus.RadixStore do
  @moduledoc """
  The Radix is the root-state of the entire Flamelex application. All events
  & user input get routed through this level.

  https://www.bounga.org/elixir/2020/02/29/genserver-supervision-tree-and-state-recovery-after-crash/

  When state changes, we broadcast out those changes, and other parts of
  the application e.g. the GUI, react to those changes. Although I did try it,
  I decided not to go with using the event-bus for updating the GUI due to
  a state change. The event-bus serves it's purpose by funneling all action
  through one choke-point, and keeps track of them etc, but just pushing
  updates to the GUI is simpler when done via a PubSub (no need to acknowledge
  events as complete), and easier to implement, since the EventBus lib we're
  using receives events in a separate process to the one where we actually
  declared the function. We could forward the state updates on to each
  Scenic c  omponent, but then we start to have problems of how to handle
  addressing... the exact problem that PubSub is a perfect solution for.
  """

  use GenServer
  require Logger

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  # fetch the radix state
  def get do
    #TODO eventually return the actual ok tuple
    {:ok, rdx_state} = GenServer.call(__MODULE__, :get_state)
    rdx_state
  end

  def init(_args) do
    # Use :continue to initialize state after normal GenServer startup
    # this prevents blocking the main app supervision tree's startup
    # since building the radix tree can take a while / might fail
    {:ok, [], {:continue, :initialize}}
  end

  # initialize state, off the main process tree bootup sequence
  def handle_continue(:initialize, _args) do
    Logger.debug("#{__MODULE__} starting up...")

    # compute state changes in a task for safety
    case Wormhole.capture(construct_init_radix_state_fn(), crush_report: true) do
      {:ok, init_radix_state} ->
        subscribe_to_events()
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

    # TODO make this a cast or a call?? Then the results can be returned to whoever sent the event,
    # and they can ack it, or use them e.g. make a new buffer - but will this lock up the RadixStore?

    # GenServer.cast(__MODULE__, {:event, e, event_shadow})

    # go with call as it forces the event to process before the next event can be consumed
    ok_err_result_tuple = GenServer.call(__MODULE__, {:event, e})

    EventBus.mark_as_completed({__MODULE__, event_shadow})

    # WHY we have to return an ok/error tuple here --
    # because this function RadixStore.process is the one I defined to be the event handling one
    # when we registered this module to handle events (it's a default defined by the event bus lib)
    # and since do_declare, was added to that library by me, it expects an ok/err tuple to be returned
    # from this - without that, do_declare fails, so plz ensure we always return the ok/err tuple here
    ok_err_result_tuple
  end

  def handle_cast(_any_msg, :initialization_failure) do
    Logger.warning(
      "#{__MODULE__} is in a failed state of `:initialization_failure`, events are being ignored."
    )

    {:noreply, :initialization_failure}
  end

  def handle_call({:event, e}, _from, radix_state) do
    # this can make a lot of noise, but sometimes I need to see it
    crush_report? = true

    case Wormhole.capture(handle_event_fn(radix_state, e), crush_report: crush_report?) do
      {:ok, :ignore} ->
        # EventBus.mark_as_completed({__MODULE__, e_shadow})
        {:reply, {:ok, :ignore}, radix_state}

      {:ok, new_radix_state} ->
        # so for now, we're just going to double-down on this being the single channel
        # I have a big debate about this because I feel like this is going to be very expensive,
        # broadcasting out multiple copies of the RadixState! However, this is
        # the simplest way to do it, and we can always optimize later. I am not able to
        # really wrap my head around how I would do it otherwise... maybe I simply push the radix state
        # through a reducer which has side-effects of broadcasting out messages on specific channels?
        # that might make it possible to broadcast smaller state changes

        # yeh I guess we could iterate just changes out instead of pushing entire changes to radixstate,
        # then other things e.g. GUI components all need to be able to handle specific changes... it gets complicated

        # one idea would be to broadcast the action first to radix state, then radix state
        # has control and can broadcast (potentially modified) actions down to it's
        # children (or just publish it on a channel), the child stores can then
        # update their state and broadcast out their changes

        # The problem becomes when we need to access different parts of the state tree, or if
        # something deeply nested within the state tree ends up affecting decisions made early/high in the funnel,
        # which maybe shouldn't happen but somehow it seems to all the time...

        # there's another idea which is, broadcast actions out to _all_ the stores, they decide individually if
        # they care about it, and if they do, then they might broadcast just their own state changes out on their own channel
        # to whatever GUI components are listening to those changes

        Flamelex.Lib.Utils.PubSub.broadcast(
          topic: :radix_state_change,
          msg: {:radix_state_change, new_radix_state}
        )

        # EventBus.mark_as_completed({__MODULE__, e_shadow})
        {:reply, {:ok, new_radix_state}, new_radix_state}

      {:error, _reason} ->
        formatted_error = ~s|\n
        id: #{e.id},
        topic: #{e.topic},
        event: #{inspect(e.data)}
        |

        Logger.error("#{__MODULE__} failed to process event.#{formatted_error}")

        # EventBus.mark_as_completed({__MODULE__, e_shadow})
        {:reply, {:error, "#{__MODULE__} failed to process event."}, radix_state}
    end
  end

  # def handle_cast({:event, e, e_shadow}, radix_state) do
  #   # this can make a lot of noise, but sometimes I need to see it
  #   crush_report? = true

  #   case Wormhole.capture(handle_event_fn(radix_state, e), crush_report: crush_report?) do
  #     {:ok, :ignore} ->
  #       EventBus.mark_as_completed({__MODULE__, e_shadow})
  #       {:noreply, radix_state}

  #     # {:fwd_to_gui, msg} ->

  #     #   EventBus.mark_as_completed({__MODULE__, e_shadow})
  #     #   {:noreply, radix_state}

  #     {:ok, new_radix_state} ->
  #       # so for now, we're just going to double-down on this being the single channel
  #       # I have a big debate about this because I feel like this is going to be very expensive,
  #       # broadcasting out multiple copies of the RadixState! However, this is
  #       # the simplest way to do it, and we can always optimize later. I am not able to
  #       # really wrap my head around how I would do it otherwise... maybe I simply push the radix state
  #       # through a reducer which has side-effects of broadcasting out messages on specific channels?
  #       # that might make it possible to broadcast smaller state changes

  #       # one idea would be to broadcast the action first to radix state, then radix state
  #       # has control and can broadcast (potentially modified) actions down to it's
  #       # children (or just publish it on a channel), the child stores can then
  #       # update their state and broadcast out their changes

  #       # The problem becomes when we need to access different parts of the state tree, or if
  #       # something deeply nested within the state tree ends up affecting decisions made early/high in the funnel,
  #       # which maybe shouldn't happen but somehow it seems to all the time...

  #       # there's another idea which is, broadcast actions out to _all_ the stores, they decide individually if
  #       # they care about it, and if they do, then they might broadcast just their own state changes out on their own channel
  #       # to whatever GUI components are listening to those changes

  #       Flamelex.Lib.Utils.PubSub.broadcast(
  #         topic: :radix_state_change,
  #         msg: {:radix_state_change, new_radix_state}
  #       )

  #       EventBus.mark_as_completed({__MODULE__, e_shadow})
  #       {:noreply, new_radix_state}

  #     {:error, _reason} ->
  #       formatted_error = ~s|\n
  #       id: #{e.id},
  #       topic: #{e.topic},
  #       event: #{inspect(e.data)}
  #       |

  #       Logger.warn("#{__MODULE__} failed to process event.#{formatted_error}")

  #       EventBus.mark_as_completed({__MODULE__, e_shadow})
  #       {:noreply, radix_state}
  #   end
  # end

  defp construct_init_radix_state_fn() do
    # have to return a zero arity function for Task.async
    fn -> Flamelex.Fluxus.RadixState.new() end
  end

  defp handle_event_fn(radix_state, %{topic: :flx_actions, data: action}) do
    # have to return a zero arity function for Task.async
    fn ->
      case Flamelex.Fluxus.RadixReducer.process(radix_state, action) do
        :ignore ->
          # EventBus.mark_as_completed({__MODULE__, e_shadow})
          :ignore

        ^radix_state ->
          # EventBus.mark_as_completed({__MODULE__, e_shadow})
          :ignore

        # cast to children ?? This might also involve a push down of new RadixState ??

        %Flamelex.Fluxus.RadixState{} = new_radix_state ->
          # EventBus.mark_as_completed({__MODULE__, e_shadow})
          new_radix_state
      end
    end
  end

  # TODO expand this to potentially accept a list of events
  defp handle_event_fn(rdx, %{topic: topic, data: event}) do
    # handlers should return a list of actions, not mutate the state directly, then we
    # map those actions to a change in state - we could update state here and also broadcast the action out???
    # broadcast the input out to components???

    # for now though I wrote my handlers badly and they mutate the radix state

    # have to return a zero arity function for Task.async



    fn ->
      handler =
        case topic do
          :flx_user_input -> Flamelex.Fluxus.Radix.UserInputHandler
          :memelex -> Flamelex.Fluxus.MemelexEventHandler
        end

      # convert the events to internal Flamelex actions
      actions =
        case handler.handle(rdx, event) do
          :ignore ->
            []

          actions when is_list(actions) ->
            actions

          not_a_list ->
            raise "Handler #{handler} needs to return a list of actions. Got: #{inspect not_a_list}"

        # :re_routed ->
          #   :ignore

          # {:route_to, :first_buffer} ->
          #   IO.puts("ROUTING TO FIRST BUFFER")
          #   # this is a bit of a hack, but it's a way to route the event to a different store
          #   # we could potentially have a list of stores to route to, and then we could
          #   # broadcast the event to all of them, and they could all decide if they want to
          #   # process it or not
          #   :ignore

          # a ->
          #   # wrap it in a list so we can still return a "list" of actions
          #   [a]
        end

      # apply these actions in sequence to mutate the RadixState to the desired end state
      actions
      |> Enum.reduce(rdx, fn action, rdx_acc ->
        case Flamelex.Fluxus.RadixReducer.process(rdx_acc, action) do
          :ignore ->
            rdx_acc

          new_rdx ->
            new_rdx
        end
      end)
    end
  end

            # apply actions to the radix state in sequence to determine the new state
          # new_rdx =
            # actions


              # process_action_fn = fn ->
              #   res = Flamelex.Fluxus.RadixReducer.process(rdx_acc, action)

              #   if res == :ignore do
              #     :ignore
              #   else
              #     res
              #   end

              #   # case Flamelex.Fluxus.RadixReducer.process(rdx_acc, action) do
              #   #   :ignore ->
              #   #     :ignore

              #   #   new_rdx ->
              #   #     new_rdx
              #   # end
              # end

              # handle inner crashes here, even inside the outer wormhole!!
              # Wormhole.capture process_action_fn do
              #   {:ok, :ignore} ->
              #     IO.puts("Ignoring the action #{inspect(action)} on purpose.")
              #     # rdx_acc
              #     :ignore

              #   {:ok, new_rdx} ->
              #     IO.puts("Applied action #{inspect(action)} and got a new rdx state")
              #     new_rdx

              #   {:error, reason} ->
              #     IO.puts(
              #       "Failed to apply action #{inspect(action)} to rdx state. Reason: #{inspect(reason)}"
              #     )

              #     # rdx_acc
              #     :ignore
              # end
            # end)

        # if new_rdx == rdx do
        #   :ignore
        # else
        #   new_rdx
        # end

        # action ->
        #   case Flamelex.Fluxus.RadixReducer.process(rdx_acc, action) do
        #     :ignore ->
        #       :ignore

        #     new_rdx ->
        #       new_rdx
        #   end

        # other ->
        #   if not is_list(other) do
        #     Logger.error("Handlers need to return a list. Got: #{inspect(other)}")
        #     :ignore
        #   else
        #     Logger.error("Unrecognised handler return value: #{inspect(other)}")
        #     :ignore
        #   end
      # end

  defp subscribe_to_events do
    EventBus.subscribe(
      {__MODULE__,
       [
         to_string(:flx_actions),
         to_string(:flx_user_input),
        #  to_string(:mmlx_events)
         to_string(:memelex)
       ]}
    )
  end
end


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
