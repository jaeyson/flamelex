defmodule Flamelex.Fluxus do
  # defdelegate start_link(args), to: Flamelex.Fluxus.TopLevelSupervisor
  # defdelegate start_link(args), to: Flamelex.Fluxus.Soup

  defdelegate user_input(ii), to: Flamelex.Fluxus.Utils
end

# defmodule Flamelex.Fluxus do
#   @moduledoc """
#   Flamelex.Fluxus implements the `flux` architecture pattern, of React.js
#   fame, in Elixir/Scenic. This module provides the interface to that
#   functionality.

#   ### background

#   https://css-tricks.com/understanding-how-reducers-are-used-in-redux/

#   ### prior art

#   https://medium.com/grandcentrix/state-management-with-phoenix-liveview-and-liveex-f53f8f1ec4d7
#   """

#   @actions :flx_actions
#   @user_input :flx_user_input

#   def radix(z) do
#     GenServer.call(Flamelex.Fluxus.RadixStore, {:redux, z})
#   end

#   # called to fire off an action
#   def action(a) do
#     # Logger.debug "Fluxus handling action `#{inspect a}`..."
#     # :ok =
#     EventBus.notify(%EventBus.Model.Event{
#       id: UUID.uuid4(),
#       topic: @actions,
#       data: {:action, a}
#     })

#     # event(@actions, {:action, a})
#   end

#   def event(topic, e) do
#     Logger.debug("pushing event for topic: #{inspect(topic)}, event: #{inspect(e)}")

#     EventBus.notify(%EventBus.Model.Event{
#       id: UUID.uuid4(),
#       topic: topic,
#       data: {:event, e}
#     })
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

# # @impl Scenic.Scene
# # def handle_event( {:click, :btn}, _, %{assigns: %{count: count}} = scene ) do
# #   count = count + 1

# #   # modify the graph to show the current click count
# #   graph =
# #     graph()
# #     |> Scenic.Graph.modify(:count, &text(&1, "Count: " <> inspect(count)))

# #   # update the count and push the modified graph
# #   scene =
# #     scene
# #     |> assign( count: count )
# #     |> push_graph( graph )

# #   # return the updated scene
# #   { :noreply, scene }
# # end

# # # handle all other (not-ignored) input...
# # def handle_event(input, _context, scene) do
# #   IO.puts "SOME NON IGNORED INPUT
# #   # Flamelex.Fluxus.handle_user_input(input)
# #   {:noreply, scene}
# # end
