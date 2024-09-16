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

  """

  defdelegate user_input(ii), to: Flamelex.Fluxus.Utils
  defdelegate action(a), to: Flamelex.Fluxus.Utils
end

# defmodule Flamelex.Fluxus do

#   @actions :flx_actions
#   @user_input :flx_user_input

#   def radix(z) do
#     GenServer.call(Flamelex.Fluxus.RadixStore, {:redux, z})
#   end

#   # declaring means we get the results back - this function also
#   # filters those results to just the ones from ActionListener

#   # having to include this is starting to feel like a bad thing...
#   def declare(a) do
#     with {:ok, results} <- do_declare(a) do
#       # NOTE - we replace this atom (the initial accumulator) in the successful case,
#       # so we have confidence when it matches (an atom can't match onto a list) the final result that this function worked
#       [final_radix_state] =
#         Enum.reduce(results, :accumulator, fn
#           # add the results from ActionListener to the accumulator, discard ones from UserInputListener
#           {Flamelex.Fluxus.ActionListener, {:ok, new_radix_state}}, acc ->
#             [new_radix_state]

#           {Flamelex.Fluxus.UserInputListener, _res}, acc ->
#             acc
#         end)

#       {:ok, final_radix_state}
#     end
#   end

#   defp do_declare(a) do
#     {:ok,
#      EventBus.declare(%EventBus.Model.Event{
#        id: UUID.uuid4(),
#        topic: @actions,
#        data: {:action, a}
#      })}
#   end

#   # called to register user-input with the Fluxus system - Scenic MUST
#   # forward input to Fluxus if it wants to be processed that way (input
#   # might be captured & processed "locally" by a component, which could
#   # then trigger an action... however if Scenic passes input through to
#   # Fluxus, then it opens up the possibility of having things like Vim
#   # keymaps that exist at a higher level than just a Scenic component)

# end
