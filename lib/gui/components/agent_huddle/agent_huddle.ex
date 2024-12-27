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
  alias Flamelex.GUI.Component.AgentHuddle.Render
  alias Flamelex.GUI.Utils.Draw

  # Validate function for Scenic component
  def validate(%{frame: %Frame{}} = data) do
    {:ok, data}
  end

  def init(scene, %{frame: %Frame{} = frame}, _opts) do
    state = Flamelex.Fluxus.RadixStore.get().apps.agent_huddle
    graph = AgentHuddle.Render.render(Scenic.Graph.build(), frame, state)

    init_scene =
      scene
      |> assign(frame: frame)
      |> assign(graph: graph)
      |> assign(state: state)
      |> push_graph(graph)

    Flamelex.Lib.Utils.PubSub.subscribe(topic: :radix_state_change)

    {:ok, init_scene}
  end

  #TODO handle frame changes

  # Handle state changes where the state hasn't changed
  def handle_info(
        {:radix_state_change, %{apps: %{agent_huddle: state}}},
        %{assigns: %{state: state}} = scene
      ) do
    # State variables in pattern match are the same; no state change occurred
    {:noreply, scene}
  end

  # Handle state changes where the state has changed
  def handle_info(
        {:radix_state_change, %{apps: %{agent_huddle: new_state}}},
        %{assigns: %{frame: frame, state: old_state}} = scene
      ) do
    IO.puts "GOT NEW AGENT HUDDLE STATE"

    # new_graph = AgentHuddle.Render.render(Scenic.Graph.build(), frame, new_state)
    new_graph = AgentHuddle.Render.render(scene.assigns.graph, frame, new_state)

    new_scene =
      scene
      |> assign(graph: new_graph)
      |> assign(state: new_state)
      |> push_graph(new_graph)

    {:noreply, new_scene}
  end

  def handle_event({:click, :chat_window_btn}, _context, scene) do
    Flamelex.Fluxus.action({__MODULE__, :open_chat_window})
    {:noreply, scene}
  end

  def handle_event({:click, :agent_settings_btn}, _context, scene) do
    Flamelex.Fluxus.action({__MODULE__, :open_agent_settings})
    {:noreply, scene}
  end


  def handle_event({:click, :five_loop_btn}, _context, scene) do
    Flamelex.Fluxus.action({__MODULE__, :open_agent_five_loop})
    {:noreply, scene}
  end

  def handle_event({:click, :activate_agent_btn}, _context, scene) do
    Flamelex.Fluxus.action({__MODULE__, {:activate_agent, scene.assigns.state.tidbit}})
    {:noreply, scene}
  end

  def handle_event({:click, :deactivate_agent_btn}, _context, scene) do
    Flamelex.Fluxus.action({__MODULE__, {:deactivate_agent, scene.assigns.state.tidbit}})
    {:noreply, scene}
  end

  def handle_event({:click, :nudge_agent_btn}, _context, scene) do
    Flamelex.Fluxus.action({__MODULE__, {:nudge_agent, scene.assigns.state.tidbit}})
    {:noreply, scene}
  end

  def handle_event(event, _context, scene) do
    IO.inspect(event, label: "GOT EEE")
    {:noreply, scene}
  end

  def handle_info(msg, scene) do
    IO.inspect(msg, label: "got msg")
    {:noreply, scene}
  end

  # # Default render function implementation
  # def render(%Frame{} = frame, %Flamelex.GUI.Component.AgentHuddle.State{} = state) do
  #   # TODO: Implement rendering logic here
  #   Scenic.Graph.build()
  #   |> Draw.background(frame, :purple)

  #   # |> Scenic.Primitives.text("Flamelex.GUI.Component.AgentHuddle",
  #   #   font_size: 24,
  #   #   translate: {frame.size.width / 2 - 50, frame.size.height / 2}
  #   # )
  # end
end
