defmodule Flamelex.GUI.Component.AgentHuddle do
  @moduledoc """
  A GUI component for Agent huddle.
  """

  use Scenic.Component
  require Logger
  alias Widgex.Frame
  alias Scenic.Graph
  alias Flamelex.Fluxus.RadixState
  alias Flamelex.GUI.Component.AgentHuddle
  alias Flamelex.GUI.Component.AgentHuddle.State

  # Validate function for Scenic component
  def validate(%{frame: %Frame{}} = data) do
    {:ok, data}
  end

  def init(scene, %{frame: %Frame{} = frame}, _opts) do
    state = Flamelex.Fluxus.RadixStore.get().apps.agent_huddle

    graph = render(frame, state)

    init_scene =
      scene
      |> assign(frame: frame)
      |> assign(graph: graph)
      |> assign(state: state)
      |> push_graph(graph)

    Flamelex.Lib.Utils.PubSub.subscribe(topic: :radix_state_change)

    {:ok, init_scene}
  end

  # Handle state changes where the state hasn't changed
  def handle_info(
        {:radix_state_change, %{apps: %{agent_huddle: state}}},
        %{assigns: %{frame: frame, state: state}} = scene
      ) do
    # State variables in pattern match are the same; no state change occurred
    {:noreply, scene}
  end

  # Handle state changes where the state has changed
  def handle_info(
        {:radix_state_change, %{apps: %{agent_huddle: new_state}}},
        %{assigns: %{frame: frame, state: old_state}} = scene
      ) do
    # State has changed; raise an error as handling is app-specific
    raise "State change handling not implemented in template"
    {:noreply, scene}
  end

  # Default render function
  def render(%Frame{} = frame, %Flamelex.GUI.Component.AgentHuddle.State{} = state) do
    # TODO: Implement rendering logic here
    # Returning an empty graph to prevent crashes by default
    Graph.build()
  end
end
