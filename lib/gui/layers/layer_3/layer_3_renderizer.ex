defmodule Flamelex.GUI.Layers.Layer3.Renderizer do
  use Scenic.Component
  alias Flamelex.GUI.Layers.Layer3
  require Logger

  @layer_3 :layer_3

  # if the frame has changed, simply re-render everything from scratch
  # we could, potentially, pass this down instead, but honestly this is good enough for 99%
  # the weird edge cases might be processes which register with specific names might get conflicts
  def render(
    %Scenic.Graph{} = graph,
    %Scenic.Scene{assigns: %{state: %{frame: %Widgex.Frame{} = old_frame}}} = scene,
    %Widgex.Frame{} = new_frame,
    %Layer3.State{} = state
  ) when old_frame != new_frame do
    # delete the old primitive to force a re-render from scratch
    graph
    |> Scenic.Graph.delete(@layer_3)
    |> draw_layer_3(new_frame, state)
  end

  # in this case frame and state both match, there's no updates so don't do anything
  # note that using same variable names in both places means it must bind exactly i.e. they're equal
  def render(
    %Scenic.Graph{} = graph,
    %Scenic.Scene{assigns: %{
        frame: %Widgex.Frame{} = frame,
        state: %Layer3.State{} = state
      }} = scene,
    %Widgex.Frame{} = frame,
    %Layer3.State{} = state
  ) do
    Logger.debug "Layer3 render called, but no change detected."
    graph
  end

  def render(
    %Scenic.Graph{} = graph,  # this is the base graph, that we will update as it's passed through the render function
    %Scenic.Scene{} = scene,  # this is the current, scene, we can use this to compare old states/frames against new ones, also we need it to find the child-pids for components we started from this component
    %Widgex.Frame{} = frame,  # this is the new Widgex frame, if this isn't supposed to change just pass back in the old one
    %Layer3.State{} = state   # this is the new Layer state, again if this isn't changing just pass the old one in and our comparison/update algorithm won't make any changes
  ) do
    # if the layer isn't in the base graph, we need to draw it,
    # otherwise proceed to render pipeline
    case Scenic.Graph.get(graph, @layer_3) do
      [] ->
        graph
        |> draw_layer_3(frame, state)

      _primitive ->
        graph
        |> render_popup_modal(frame, state)
    end
  end

  # this function literally always adds a new layer to the graph,
  # so we need to only call it when this component got deleted/hasn't been drawn yet
  defp draw_layer_3(graph, frame, state) do
    graph
    |> Scenic.Primitives.group(fn graph ->
      graph
      |> render_popup_modal(frame, state)
    end, id: @layer_3)
  end

  @popup_modal :popup_modal
  defp render_popup_modal(graph, frame, %{open_memex_popup_open?: false} = state) do
    case Scenic.Graph.get(graph, @popup_modal) do
      [] ->
        # we aren't supposed to show the popup, and it isn't there, so just do nothing
        graph

      _primitive ->
        # hide the modal by straight up deleting it !
        graph
        |> Scenic.Graph.delete(@popup_modal)
    end
  end

  defp render_popup_modal(graph, frame, %{open_memex_popup_open?: true} = state) do
    case Scenic.Graph.get(graph, @popup_modal) do
      [] ->
        # draw the modal
        graph
        |> Scenic.Primitives.group(fn graph ->
          graph
          |> render_background(frame, state)
        end, id: @popup_modal)

      _primitive ->
        # push the modal through the render/update pipeline
        graph
        |> render_background(frame, state)
    end
  end

  @background :background
  @semi_transparent_white {255, 255, 255, Integer.floor_div(255, 3)}
  defp render_background(graph, frame, _state) do
    case Scenic.Graph.get(graph, @background) do
      [] ->
        graph
        |> Scenic.Primitives.rect(frame.size.box,
            id: @background,
            fill: {:color_rgba, @semi_transparent_white},
            translate: frame.pin.point
        )

      _primitive ->
        # TODO right now we cant change the color of the background but eventually, we will
        graph
        # |> Scenic.Graph.modify(@background,
        #   &Scenic.Primitives.update_opts(&1, fill: new_state.colors.slate)
        # )
    end
  end
end
