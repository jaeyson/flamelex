defmodule Flamelex.GUI.Layers.Layer4 do
  use Scenic.Component
  alias Flamelex.GUI.Layers.Layer4
  require Logger


  def validate(%{frame: %Widgex.Frame{} = frame} = _data) do
    {:ok, frame}
  end

  def init(
    %Scenic.Scene{} = scene,
    %Widgex.Frame{} = frame,
    _opts
  ) do

    init_state = Flamelex.Fluxus.RadixStore.get().layers.four
    init_graph = Layer4.Renderizer.render(Scenic.Graph.build(), scene, frame, init_state)

    init_scene =
      scene
      |> assign(frame: frame)
      |> assign(state: init_state)
      |> assign(graph: init_graph)
      |> push_graph(init_graph)

    Flamelex.Lib.Utils.PubSub.subscribe(topic: :radix_state_change)

    {:ok, init_scene}
  end

  # the variable `l1_state` exactly matches in both places
  # of the pattern-match, therefore no state change occured
  def handle_info(
        {:radix_state_change, %{layers: %{four: l_state}}},
        %{assigns: %{state: l_state}} = scene
      ) do
    {:noreply, scene}
  end

  # our state changed else we would have matched on clause above
  def handle_info(
    {:radix_state_change, %{layers: %{four: new_l_state}}},
    scene
  ) do

    new_graph =
      Layer4.Renderizer.render(scene.assigns.graph, scene, scene.assigns.frame, new_l_state)

    new_scene =
      scene
      |> assign(state: new_l_state)
      |> assign(graph: new_graph)
      |> push_graph(new_graph)

    {:noreply, new_scene}
  end

end
