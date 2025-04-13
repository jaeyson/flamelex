defmodule Flamelex.GUI.Layers.Layer3 do
  @moduledoc """
  Layer 3 contains/concerns all popups, modals & overlays.
  """
  use Scenic.Component
  alias Flamelex.GUI.Layers.Layer3

  def validate(%{frame: %Widgex.Frame{}} = data) do
    {:ok, data}
  end

  def init(
    %Scenic.Scene{} = scene,
    %{frame: %Widgex.Frame{} = frame},
    _opts
  ) do

    # fetch a new fresh Layer state
    state = Flamelex.Fluxus.RadixStore.get().layers.three

    graph = Layer3.Renderizer.render(Scenic.Graph.build(), scene, frame, state)

    new_scene =
      scene
      |> assign(frame: frame)
      |> assign(state: state)
      |> assign(graph: graph)
      |> push_graph(graph)

    #TODO use more local channels when state gets scoped down to specific processes instead of one big radix state
    #TODO also `radix_state_change` is just... not a good name for the topic, but now it's almost ubiquitous
    Flamelex.Lib.Utils.PubSub.subscribe(topic: :radix_state_change)

    {:ok, new_scene}
  end

  # in this case, the state hasn't changed, so we don't have to do anything
  def handle_info(
    {:radix_state_change, %{layers: %{three: state}}},
    %{assigns: %{state: state}} = scene
  ) do
    {:noreply, scene}
  end


  def handle_info(
    {:radix_state_change, %{layers: %{three: new_state}}},
    scene
  ) do
    new_graph = Layer3.Renderizer.render(
      scene.assigns.graph,
      scene,
      scene.assigns.frame,
      new_state
    )

    new_scene =
      scene
      |> assign(state: new_state)
      |> assign(graph: new_graph)
      |> push_graph(new_graph)

    {:noreply, new_scene}
  end

  def handle_input(
        {:cursor_button, {:btn_left, 1, _, _}},
        :close_modal_btn,
        scene
      ) do
    # # Close the modal box
    # new_state = %{scene.assigns.state | open_memex_popup_open?: false}
    # new_graph = Layer3.Renderizer.render(scene.assigns.graph, scene, scene.assigns.frame, new_state)

    # scene
    # |> assign(state: new_state)
    # |> assign(graph: new_graph)
    # |> push_graph(new_graph)
    # |> noreply()
    IO.puts "CLICKED CANCEL"

    Flamelex.Fluxus.action({:memex_aperi, :close})

    {:noreply, scene}
  end

  def handle_input(
        {:cursor_button, _btn},
        :close_modal_btn,
        scene
      ) do
    # ignoring any other clicks from this button
    {:noreply, scene}
  end
end
