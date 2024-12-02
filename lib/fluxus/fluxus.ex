defmodule Flamelex.Fluxus do
  @moduledoc """
  Flamelex.Fluxus implements the `flux` architecture pattern, of React.js
  fame, in Elixir/Scenic. This module provides the interface to that
  functionality.

  ### background

  https://css-tricks.com/understanding-how-reducers-are-used-in-redux/

  ### prior art

  https://medium.com/grandcentrix/state-management-with-phoenix-liveview-and-liveex-f53f8f1ec4d7

  On handlers vs reducers vs mutators

  There's a basic structure to Fluxus which is that Radix is the `root` of the state tree. The
  <!-- state tree is a tree of maps, where each map is a node in the tree. The root of the tree is -->
  whole thing is just one big state tree really, with lots of state being stored in the radix
  state because that's the "highest level" of the state and when you fire an event you probably
  need the entire application state to figure out what to do

  This isn't globally true though and obviously you can have state stored in lower places in the
  state tree - these then have their own StateStore process. Actions will still get routed through
  the radix state, but the radix state will then delegate to the appropriate StateStore process e.g. MemexStore

  ### actions

  Actions are the things that happen in the system. They are the things that the user does, or
  that the system does in response to the user. They are the things that happen in the system that
  cause the state to change.

  We can fire actions in lots of ways
  - programatically, from IEx
  - we can wire up buttons in the UI to fire actions
  - we can map user input to actions (e.g. key presses) and we can use the global state of the application + keypress to fire different actions in different contexts

  ### reducers

  Reducers are the functions that take the current state of the system and an action, and return the new state of the system. They are the things that
  define how the state of the system changes in response to an action. They mutate the state of the application in a way that's declared as pure functions (no side effects)

  ### mutators

  Mutators are really just helpers to the reducers, we can define some common transformations/mutations of the radix state,
  in a way that lets us chain together changes to the state in a way that's easy to read and understand, and that's easy to test.
  However the logic of what mutations to use would reside in the reducers, and the mutators would be called from the reducers,
  so that mutations can be composed together and kept separate from the logic of the reducers (which decides "what to do" vs the mutators "how to do it")

  ### listeners

  Listeners are the things that listen for events in the system. Note that these events are actually different from "actions" - actions are things that happen in the system, whereas events are things that the system can listen for. This is a subtle distinction but it's important. Events are things that the system can listen for, and then do something in response to. Actions are things that the system can do, and then the system can listen for events that are triggered by those actions.
  The implementation of both systems is essentialyl the same, but semantically, this difference is important (actually, is it??)

  #   # called to register user-input with the Fluxus system - Scenic MUST
  #   # forward input to Fluxus if it wants to be processed that way (input
  #   # might be captured & processed "locally" by a component, which could
  #   # then trigger an action... however if Scenic passes input through to
  #   # Fluxus, then it opens up the possibility of having things like Vim
  #   # keymaps that exist at a higher level than just a Scenic component)

  ### how the gui gets updated

  Inside fluxus we break the state down into component processes


  """

  # defdelegate user_input(ii), to: Flamelex.Fluxus.Utils

  #   #   @doc """
#   #   This function is called to channel all user input, e.g. keypresses,
#   #   through the FluxusRadix, where they can be converted into actions.

#   #   This function handles user input. All input from the entire GUI gets
#   #   routed through here (it gets sent here by Flamelex.GUI.RootScene.handle_input/3)

#   #   We use the RadixState (which includes global variables such as which
#   #   mode we are in, the input history [to allow chaining of keystrokes\] etc),
#   #   as well as the input itself, to compute the new state.

#   #   The effect of most user input will be either to ignore it, or to dispatch
#   #   an action - this is achieved by sending a new msg to the FluxusRadix, which
#   #   will in turn be handled by spinning up a new Task process to handle it.

#   #     ##TODO it's simpler to route these different right now.
#   #     # call Flamelex.Fluxus.UserInput.

#   #     # This is an example of the "state-centered" approach - we keep
#   #     # wanting to store things in the scene - maybe I should just put everything
#   #     # in here lol

#   #     # The whole idea of 'fluxus' is to seperate out the state of your
#   #     # application, from the state of your Scenic GUI processes

#   #     #TODO this is one area of quandary - either I spin up a new process
#   #     # to handle everything (nice security), but then I have to wait here
#   #     # for a callback. Or, if I don't wait, then I have to give up my
#   #     # ability to mutate the scene here.

#   #     # Maybe how this should work is - instead of messaging a GenServer
#   #     # which holds the root state, we just start a process, which fetches
#   #     # a copy of the root state inside itself?
#   #   """

  @flx_actions :flx_actions
  def action(a) do
    EventBus.notify(%EventBus.Model.Event{
      id: UUID.uuid4(),
      topic: @flx_actions,
      data: a
    })
  end

  @flx_user_input :flx_user_input
  def user_input(u_input) do
    EventBus.notify(%EventBus.Model.Event{
      id: UUID.uuid4(),
      topic: @flx_user_input,
      data: u_input
    })
  end

  # declaring means we get the results back - this function also
  # filters those results to just the ones from ActionListener
  # having to include this is starting to feel like a bad thing... not really though, the lib computes the result & throws it away !
  def declare(a) do
    case do_declare(a) do
      [{Flamelex.Fluxus.RadixStore, :ignore}] ->
        {:ok, :ignore}

      [{Flamelex.Fluxus.RadixStore, {:ok, %Flamelex.Fluxus.RadixState{} = r}}] ->
        {:ok, r}

      [{Flamelex.Fluxus.RadixStore, {:error, reason}}] ->
        raise "Was not able to declare action `#{inspect(a)}` successfully - #{reason}"
        {:error, "Failed to declare action."}
    end
  end

  defp do_declare(a) do
    EventBus.declare(%EventBus.Model.Event{
      id: UUID.uuid4(),
      topic: @flx_actions,
      data: a
    })
  end
end




    # IO.inspect(results)
    # NOTE - we replace this atom (the initial accumulator) in the successful case,
    # so we have confidence when it matches (an atom can't match onto a list) the final result that this function worked
    # [final_radix_state] =
    #   Enum.reduce(results, :accumulator, fn
    #     # add the results from ActionListener to the accumulator, discard ones from UserInputListener
    #     {Flamelex.Fluxus.ActionListener, {:ok, new_radix_state}}, acc ->
    #       [new_radix_state]

    #     {Flamelex.Fluxus.UserInputListener, _res}, acc ->
    #       acc
    #   end)

    # {:ok, final_radix_state}
    # end


# defmodule ScenicWidgets.Fluxus do
#    @moduledoc """
#    Flamelex.Fluxus implements the `flux` architecture pattern, of React.js
#    fame, in Elixir/Scenic. This module provides the interface to that
#    functionality.

#    ### background

#    https://css-tricks.com/understanding-how-reducers-are-used-in-redux/

#    ### prior art

#    https://medium.com/grandcentrix/state-management-with-phoenix-liveview-and-liveex-f53f8f1ec4d7
#    """

#    #TODO during boot, save all the app-specific stateful info in a small Agent, then just re-fetch it every time soeone calls `action` or `declare`

#    # called to fire off an action
#    def action(a) do
#       #Logger.debug "Fluxus handling action `#{inspect a}`..."
#       :ok = EventBus.notify(%EventBus.Model.Event{
#          id: UUID.uuid4(),
#          topic: :general,
#          data: {:action, a}
#       })
#    end

#    # declaring means we get the results back - this function also
#    # filters those results to just the ones from ActionListener
#    def declare(a) do
#       with {:ok, results} <- do_declare(a) do
#          [final_radix_state] =
#             Enum.reduce(results, :accumulator, fn # NOTE - we replace this atom, so we have confidence when it matches the final result that this function worked
#                # add the results from ActionListener to the accumulator, discard ones from UserInputListener
#                #TODO maybe I can just chck if the last moduler is `ActionListener`??
#                {Flamelex.Fluxus.ActionListener, {:ok, new_radix_state}}, acc ->
#                   [new_radix_state]
#                {Flamelex.Fluxus.UserInputListener, _res}, acc ->
#                   acc
#             end)

#          {:ok, final_radix_state}
#       end
#    end

#    def do_declare(a) do
#       {:ok, EventBus.declare(%EventBus.Model.Event{
#          id: UUID.uuid4(),
#          topic: :general,
#          data: {:action, a}
#       })}
#    end

#   # called to register user-input with the Fluxus system - Scenic MUST
#   # forward input to Fluxus if it wants to be processed that way (input
#   # might be captured & processed "locally" by a component, which could
#   # then trigger an action... however if Scenic passes input through to
#   # Fluxus, then it opens up the possibility of having things like Vim
#   # keymaps that exist at a higher level than just a Scenic component)
#   @doc """
#   This function is called to channel all user input, e.g. keypresses,
#   through the FluxusRadix, where they can be converted into actions.

#   This function handles user input. All input from the entire GUI gets
#   routed through here (it gets sent here by Flamelex.GUI.RootScene.handle_input/3)

#   We use the RadixState (which includes global variables such as which
#   mode we are in, the input history [to allow chaining of keystrokes\] etc),
#   as well as the input itself, to compute the new state.

#   The effect of most user input will be either to ignore it, or to dispatch
#   an action - this is achieved by sending a new msg to the FluxusRadix, which
#   will in turn be handled by spinning up a new Task process to handle it.

#     ##TODO it's simpler to route these different right now.
#     # call Flamelex.Fluxus.UserInput.

#     # This is an example of the "state-centered" approach - we keep
#     # wanting to store things in the scene - maybe I should just put everything
#     # in here lol

#     # The whole idea of 'fluxus' is to seperate out the state of your
#     # application, from the state of your Scenic GUI processes

#     #TODO this is one area of quandary - either I spin up a new process
#     # to handle everything (nice security), but then I have to wait here
#     # for a callback. Or, if I don't wait, then I have to give up my
#     # ability to mutate the scene here.

#     # Maybe how this should work is - instead of messaging a GenServer
#     # which holds the root state, we just start a process, which fetches
#     # a copy of the root state inside itself

#   # @impl Scenic.Scene
#   # def handle_event( {:click, :btn}, _, %{assigns: %{count: count}} = scene ) do
#   #   count = count + 1

#   #   # modify the graph to show the current click count
#   #   graph =
#   #     graph()
#   #     |> Scenic.Graph.modify(:count, &text(&1, "Count: " <> inspect(count)))

#   #   # update the count and push the modified graph
#   #   scene =
#   #     scene
#   #     |> assign( count: count )
#   #     |> push_graph( graph )

#   #   # return the updated scene
#   #   { :noreply, scene }
#   # end

#   # # handle all other (not-ignored) input...
#   # def handle_event(input, _context, scene) do
#   #   IO.puts "SOME NON IGNORED INPUT
#   #   # Flamelex.Fluxus.handle_user_input(input)
#   #   {:noreply, scene}
#   # end

#   """
#   def input(ii) do
#     EventBus.notify(%EventBus.Model.Event{
#       id: UUID.uuid4(),
#       topic: :general,
#       data: {:input, ii}
#     })
#   end

# end
