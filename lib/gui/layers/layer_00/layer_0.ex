defmodule Flamelex.GUI.Layers.Layer0 do
  use Scenic.Component
  alias Flamelex.GUI.Component.Renseijin

  def validate(%{frame: %Widgex.Frame{}} = data) do
    {:ok, data}
  end

  def init(
        %Scenic.Scene{} = scene,
        %{frame: %Widgex.Frame{} = frame},
        _opts
      ) do
    # state = Renseijin.State.new()

    graph =
      Scenic.Graph.build()
      |> Renseijin.add_to_graph(%{
        frame: frame
        # state: state
      })

    new_scene =
      scene
      |> assign(frame: frame)
      |> assign(graph: graph)
      # |> assign(state: state)
      |> push_graph(graph)

    {:ok, new_scene}
  end
end
