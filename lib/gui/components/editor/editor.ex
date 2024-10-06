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

    Flamelex.Lib.Utils.PubSub.subscribe(topic: {:buffers, hd(state.buffers).uuid})

    {:ok, init_scene}
  end

  def handle_info({:move_cursor, _dir, _x}, scene) do
    # sort of weird, we fire this event but also recv it, we just ignore it but cursor needs to catch it
    {:noreply, scene}
  end
end
