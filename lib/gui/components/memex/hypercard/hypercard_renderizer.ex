defmodule Memelex.GUI.Components.HyperCard.Renderizer do



  # def render(
  #   %Scenic.Graph{} = graph,
  #   %Scenic.Scene{assigns: %{state: %{frame: %Widgex.Frame{} = old_frame}}} = scene,
  #   %Widgex.Frame{} = new_frame,
  #   # %Layer3.State{} = state
  #   state
  # ) when old_frame != new_frame do
  #   # delete the old primitive to force a re-render from scratch
  #   graph
  #   # |> Scenic.Graph.delete(@layer_3)
  #   # |> draw_layer_3(new_frame, state)
  # end

  # defp hypercard()

  def render(graph, scene, frame, state) do
    graph
    |> Scenic.Primitives.rect(frame.size.box, fill: :red, translate: frame.pin.point)
  end

end
