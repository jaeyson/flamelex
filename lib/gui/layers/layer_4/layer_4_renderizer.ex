defmodule Flamelex.GUI.Layers.Layer4.Renderizer do
  use Scenic.Component
  alias Flamelex.GUI.Layers.Layer4
  require Logger

  @layer_4 :layer_4

  # if the frame has changed, simply re-render everything from scratch
  # we could, potentially, pass this down instead, but honestly this is good enough for 99%
  # the weird edge cases might be processes which register with specific names might get conflicts
  # def render(
  #   %Scenic.Graph{} = graph,
  #   %Scenic.Scene{assigns: %{state: %{frame: %Widgex.Frame{} = old_frame}}} = scene,
  #   %Widgex.Frame{} = new_frame,
  #   %Layer3.State{} = state
  # ) when old_frame != new_frame do
  #   # delete the old primitive to force a re-render from scratch
  #   graph
  #   |> Scenic.Graph.delete(@layer_4)
  #   |> draw_layer_4(new_frame, state)
  # end

  def render(
    %Scenic.Graph{} = graph,
    %Scenic.Scene{} = scene,
    %Widgex.Frame{} = frame,
    %Layer4.State{} = state
  ) do
    IO.puts "WARNING re-drawing layer 4..."
    # delete the old primitive to force a re-render from scratch
    graph
    |> Scenic.Graph.delete(@layer_4)
    |> draw_layer_4(frame, state)
  end

  defp draw_layer_4(graph, frame, state) do
    graph
    |> Scenic.Primitives.group(fn graph ->
      graph
      # |> render_popup_modal(frame, state)
    end, id: @layer_4)
  end

end
