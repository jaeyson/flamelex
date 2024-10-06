defmodule Flamelex.GUI.Component.Editor do
  @moduledoc """
  A GUI component for Editor.
  """

  use Scenic.Component
  require Logger
  alias Widgex.Frame
  alias Scenic.Graph
  alias Flamelex.Fluxus.RadixState
  alias Flamelex.GUI.Component.Editor
  alias Flamelex.GUI.Component.Editor.State
  alias Flamelex.GUI.Component.Editor.Render
  alias Flamelex.GUI.Utils.Draw

  # Validate function for Scenic component
  def validate(%{frame: %Frame{}} = data) do
    {:ok, data}
  end

  def init(scene, %{frame: %Frame{} = frame}, _opts) do
    state = Flamelex.Fluxus.RadixStore.get().apps.editor
    graph = Render.go(frame, state)

    init_scene =
      scene
      |> assign(frame: frame)
      |> assign(graph: graph)
      |> assign(state: state)
      |> push_graph(graph)

    Flamelex.Lib.Utils.PubSub.subscribe(topic: :radix_state_change)
    Flamelex.Lib.Utils.PubSub.subscribe(topic: {:buffers, hd(state.buffers).uuid})

    {:ok, init_scene}
  end

  # Handle state changes where the state hasn't changed
  def handle_info(
        {:radix_state_change, %{apps: %{editor: state}}},
        %{assigns: %{frame: frame, state: state}} = scene
      ) do
    # State variables in pattern match are the same; no state change occurred
    {:noreply, scene}
  end

  # Handle state changes where the state has changed
  def handle_info(
        {:radix_state_change, %{apps: %{editor: new_state}}},
        %{assigns: %{frame: frame, state: old_state}} = scene
      ) do
    # State has changed; raise an error as handling is app-specific
    raise "State change handling not implemented in template"
    {:noreply, scene}
  end

  def handle_info({:move_cursor, _dir, _x}, scene) do
    # sort of weird, we fire this event but also recv it, we just ignore it but cursor needs to catch it
    {:noreply, scene}
  end

  def handle_info({:user_input_fwd, input}, %{assigns: %{state: state}} = scene) do
    Logger.debug("Editor received input: #{inspect(input)}")

    # user input handle returns a list of actions, which must be processed by the reducer
    # maybe on the component level we don't bother with that... though I think it will be awesome for undo/redo etc!

    # TODO use wormhole, abstract this out somewhere
    case Editor.UserInputHandler.handle(state, input) do
      :ignore ->
        {:noreply, scene}

      :re_routed ->
        IO.puts("RE ROUTED #{inspect(input)}")
        {:noreply, scene}

      actions when is_list(actions) ->
        # TODO this gets into a repeat of the previous problem... I want to apply the actions,
        # but I DONT wnt to always re-render!!

        # apply actions to the radix state in sequence to determine the new state
        new_state =
          actions
          |> Enum.reduce(state, fn action, state_acc ->
            case Editor.Reducer.process(state_acc, action) do
              :ignore ->
                state_acc

              # :re_routed ->
              #   state_acc

              %Editor.State{} = new_state ->
                new_state
            end
          end)

        # This ideally is where Scenic is able to go, no need to re-render if the state hasn't changed,
        new_graph = Render.go(scene.assigns.frame, new_state)

        new_scene =
          scene
          |> assign(state: new_state)
          |> push_graph(new_graph)

        # cast_children(new_state.buffers)

        {:noreply, new_scene}
    end

    # new_state = Editor.UserInputHandler.handle(state, input)

    # # TODO somehow we want to resist re-rendering all the time, we should mutate instead
    # # by pushing input events down to the lowest level that can handle them
    # new_graph = Render.go(scene.assigns.frame, new_state)

    # new_scene =
    #   scene
    #   |> assign(state: new_state)
    #   |> push_graph(new_graph)

    # {:noreply, new_scene}
  end
end
