defmodule Flamelex.GUI.Layers.NeoLayer01 do
  use Widgex.Layer

  def cast_rdx_to_layer_state(_radix_state) do
    {:ok, %{}}
  end

  def render(frame, _state) do
    graph =
      Scenic.Graph.build()
      |> Scenic.Primitives.rectangle(frame.size.box, fill: :blue)

    {:ok, graph}
  end
end
