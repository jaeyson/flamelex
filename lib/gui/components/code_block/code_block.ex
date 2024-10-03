defmodule Flamelex.GUI.Component.CodeBlock do
  @moduledoc """
  A GUI component for Code block.
  """

  use Scenic.Component
  require Logger
  alias Widgex.Frame
  alias Scenic.Graph
  alias Flamelex.Fluxus.RadixState
  alias Flamelex.GUI.Component.CodeBlock
  alias Flamelex.GUI.Component.CodeBlock.State
  alias Flamelex.GUI.Component.CodeBlock.Render
  alias Flamelex.GUI.Utils.Draw

  # Validate function for Scenic component
  def validate(%{frame: %Frame{}} = data) do
    {:ok, data}
  end

  def init(scene, %{frame: %Frame{} = frame, state: %State{} = state}, _opts) do
    graph = Render.go(frame, state)

    init_scene =
      scene
      |> assign(frame: frame)
      |> assign(graph: graph)
      |> assign(state: state)
      |> push_graph(graph)

    # Flamelex.Lib.Utils.PubSub.subscribe(topic: :radix_state_change)

    {:ok, init_scene}
  end

  # Handle state changes where the state hasn't changed
  # def handle_info(
  #       {:radix_state_change, %{apps: %{code_block: state}}},
  #       %{assigns: %{frame: frame, state: state}} = scene
  #     ) do
  #   # State variables in pattern match are the same; no state change occurred
  #   {:noreply, scene}
  # end

  # # Handle state changes where the state has changed
  # def handle_info(
  #       {:radix_state_change, %{apps: %{code_block: new_state}}},
  #       %{assigns: %{frame: frame, state: old_state}} = scene
  #     ) do
  #   # State has changed; raise an error as handling is app-specific
  #   raise "State change handling not implemented in template"
  #   {:noreply, scene}
  # end
end
