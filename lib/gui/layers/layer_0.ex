defmodule Flamelex.GUI.Layers.Layer0 do
  use Scenic.Component
  alias Flamelex.GUI.Layers.Layer01
  alias Flamelex.GUI.Component.Renseijin
  alias Flamelex.GUI.Component.RenseijinComponent
  require Logger

  def validate(%{frame: %Widgex.Frame{}} = data) do
    {:ok, data}
  end

  def init(
        %Scenic.Scene{} = scene,
        %{frame: %Widgex.Frame{} = frame},
        opts \\ []
      ) do
    {:ok, graph} = render(frame, %{})

    new_scene =
      scene
      |> assign(frame: frame)
      |> assign(graph: graph)
      |> push_graph(graph)

    # Flamelex.Lib.Utils.PubSub.subscribe(topic: :radix_state_change)

    {:ok, new_scene}
  end

  def render(frame, state) do
    Scenic.Graph.build()
    |> render(frame, state)
  end

  def render(graph, frame, _state) do
    Wormhole.capture(
      fn ->
        r_state = Flamelex.GUI.Component.Renseijin.State.new()

        graph
        |> RenseijinComponent.add_to_graph(%{
          frame: frame,
          state: r_state
        })
      end,
      crush_report: true
    )
  end
end
