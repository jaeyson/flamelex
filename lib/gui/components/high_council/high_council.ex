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
        %{assigns: %{frame: frame}} = scene
      ) do
    # State has changed; raise an error as handling is app-specific
    # TODO this had a really weird but interesting failure...
    # by causing a crash here, we effectively re-render the component, and it "just works"
    # raise "State change handling not implemented in template"

    new_graph = Render.go(frame, new_state)

    new_scene =
      scene
      |> assign(graph: new_graph)
      |> assign(state: new_state)
      |> push_graph(new_graph)

    {:noreply, new_scene}
  end

  def handle_event({:click, :new_agent}, _from, scene) do
    # IO.puts("Making a new agent")
    # scene.assigns.state
    # |> Memelex.My.Wiki.update(%{priority: :higher})
    Flamelex.Fluxus.action({__MODULE__, :new_agent})

    {:noreply, scene}
  end

  def handle_event({:click, :cancel_modal}, _from, scene) do
    Flamelex.Fluxus.action({__MODULE__, :cancel_new_agent_creation})
    {:noreply, scene}
  end

  def handle_event({:click, :save_agent}, _from, scene) do
    # TODO handle crashes, bad results here
    Memelex.My.Agents.new(scene.assigns.new_agent_name)
    Flamelex.Fluxus.action({__MODULE__, :cancel_new_agent_creation})

    {:noreply, scene |> assign(new_agent_name: "")}
  end

  def handle_event({:value_changed, :agent_name, name}, _from, scene) do
    {:noreply, scene |> assign(new_agent_name: name)}
  end
end
