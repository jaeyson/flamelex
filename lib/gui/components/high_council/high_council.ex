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

  # Validate function for Scenic component
  def validate(%{frame: %Frame{}} = data) do
    {:ok, data}
  end

  def init(scene, %{frame: %Frame{} = frame}, _opts) do
    # state = Flamelex.Fluxus.RadixStore.get().apps.flamelex/gui/component/high_council
    state = Flamelex.Fluxus.RadixStore.get().apps.high_council

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

  # # Handle state changes where the state hasn't changed
  # def handle_info(
  #       {:radix_state_change, %{apps: %{flamelex/gui/component/high_council: state}}},
  #       %{assigns: %{frame: frame, state: state}} = scene
  #     ) do
  #   # State variables in pattern match are the same; no state change occurred
  #   {:noreply, scene}
  # end

  # # Handle state changes where the state has changed
  # def handle_info(
  #       {:radix_state_change, %{apps: %{flamelex/gui/component/high_council: new_state}}},
  #       %{assigns: %{frame: frame, state: old_state}} = scene
  #     ) do
  #   # State has changed; raise an error as handling is app-specific
  #   raise "State change handling not implemented in template"
  #   {:noreply, scene}
  # end

  # Default render function
  def render(%Frame{} = frame, %State{} = state) do
    # TODO: Implement rendering logic here
    # Returning an empty graph to prevent crashes by default
    Graph.build()
    |> Scenic.Primitives.rectangle(frame.size.box, fill: :orange, t: frame.pin.point)
    |> Scenic.Primitives.rectangle(header_frame(frame).size.box,
      fill: :green,
      t: header_frame(frame).pin.point
    )
    |> ScenicWidgets.Markup.Header1.draw(%{frame: header_frame(frame), text: "High Council"})
  end

  def header_frame(frame) do
    frame
    |> Frame.shrink(0.1, :top)
  end
end
