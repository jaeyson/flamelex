defmodule Flamelex.GUI.Component.HighCouncil do
  @moduledoc """
  A GUI component for High council.
  """

  use Scenic.Component
  require Logger
  alias Widgex.Frame
  alias Scenic.Graph
  alias Flamelex.Fluxus.RadixState
  alias Flamelex.GUI.Component.HighCouncil
  alias Flamelex.GUI.Component.HighCouncil.State
  alias Flamelex.GUI.Component.HighCouncil.Render

  # Validate function for Scenic component
  def validate(%{frame: %Frame{}} = data) do
    {:ok, data}
  end

  def init(scene, %{frame: %Frame{} = frame}, _opts) do
    # state = Flamelex.Fluxus.RadixStore.get().apps.flamelex/gui/component/high_council
    state = Flamelex.Fluxus.RadixStore.get().apps.high_council
    graph = Render.go(frame, state)

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
        {:radix_state_change, %{apps: %{high_council: state}}},
        %{assigns: %{frame: frame, state: state}} = scene
      ) do
    # State variables in pattern match are the same; no state change occurred
    {:noreply, scene}
  end

  # Handle state changes where the state has changed
  def handle_info(
        {:radix_state_change, %{apps: %{high_council: new_state}}},
        %{assigns: %{frame: frame, state: old_state}} = scene
      ) do
    # State has changed; raise an error as handling is app-specific
    raise "State change handling not implemented in template"
    {:noreply, scene}
  end

  def handle_event({:click, :new_agent}, _from, scene) do
    # IO.puts("Making a new agent")
    # scene.assigns.state
    # |> Memelex.My.Wiki.update(%{priority: :higher})
    Flamelex.Fluxus.action({__MODULE__, :new_agent})

    {:noreply, scene}
  end
end
