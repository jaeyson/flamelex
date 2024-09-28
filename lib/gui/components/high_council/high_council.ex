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

    # [l, mid, r] = Frame.col_split(frame, 3)

    # grid =
    #   Widgex.Frame.Grid.new(frame)
    #   # Proportions for header, content, footer
    #   |> Widgex.Frame.Grid.rows([0.1, 0.8, 0.1])
    #   # Fixed width sidebars and auto content
    #   |> Widgex.Frame.Grid.columns([200, :auto, 200])
    #   |> Widgex.Frame.Grid.row_gap(10)
    #   |> Widgex.Frame.Grid.column_gap(10)
    #   |> Widgex.Frame.Grid.define_areas(%{
    #     # Spans first row across all columns
    #     header: {0, 0, 1, 3},
    #     footer: {2, 0, 1, 3},
    #     sidebar_left: {1, 0, 1, 1},
    #     content: {1, 1, 1, 1},
    #     sidebar_right: {1, 2, 1, 1}
    #   })

    #     banner_row_proportion = 0.10
    # content_row_proportion = 0.90 / 15  # 0.06
    # rows_proportions = [banner_row_proportion] ++ List.duplicate(content_row_proportion, 15)

    # columns_proportions = [1.0 / 3.0, 1.0 / 3.0, 1.0 / 3.0]

    # grid =
    #   Widgex.Frame.Grid.new(frame)
    #   |> Widgex.Frame.Grid.rows(rows_proportions)
    #   |> Widgex.Frame.Grid.columns(columns_proportions)
    #   |> Widgex.Frame.Grid.row_gap(0)
    #   |> Widgex.Frame.Grid.column_gap(0)
    #   |> Widgex.Frame.Grid.define_areas(%{
    #     banner: {0, 0, 1, 3}  # Spans the first row across all 3 columns
    #   })

    #     cell_frames = Widgex.Frame.Grid.calculate(grid)

    #     # content_frame = Widgex.Frame.Grid.area_frame(grid, cell_frames, :content)
    #     banner_frame = Widgex.Frame.Grid.area_frame(grid, cell_frames, :banner)

    # Define grid proportions for 46 frames total
    banner_row_proportion = 0.10
    # 0.06
    content_row_proportion = 0.90 / 15
    rows_proportions = [banner_row_proportion] ++ List.duplicate(content_row_proportion, 15)
    columns_proportions = [1.0 / 3.0, 1.0 / 3.0, 1.0 / 3.0]

    grid =
      Widgex.Frame.Grid.new(frame)
      |> Widgex.Frame.Grid.rows(rows_proportions)
      |> Widgex.Frame.Grid.columns(columns_proportions)
      |> Widgex.Frame.Grid.row_gap(0)
      |> Widgex.Frame.Grid.column_gap(0)
      |> Widgex.Frame.Grid.define_areas(%{
        banner: {0, 0, 1, 3}
      })

    cell_frames = Widgex.Frame.Grid.calculate(grid)
    banner_frame = Widgex.Frame.Grid.area_frame(grid, cell_frames, :banner)

    c1 = Widgex.Frame.Grid.cell_frame(cell_frames, 2, 2)
    c2 = Widgex.Frame.Grid.cell_frame(cell_frames, 2, 7)
    c3 = Widgex.Frame.Grid.cell_frame(cell_frames, 1, 3)
    c4 = Widgex.Frame.Grid.cell_frame(cell_frames, 3, 3)

    Graph.build()
    |> Scenic.Primitives.rectangle(frame.size.box, fill: :orange, t: frame.pin.point)
    |> Scenic.Primitives.rectangle(banner_frame.size.box,
      fill: :green,
      t: header_frame(frame).pin.point
    )
    |> ScenicWidgets.Markup.Header1.draw(%{frame: banner_frame, text: "High Council"})
    |> Scenic.Primitives.rectangle(c1.size.box, fill: :blue, t: c1.pin.point)

    # |> Scenic.Primitives.rectangle(c2.size.box, fill: :grey, t: c2.pin.point)
    # |> Scenic.Primitives.rectangle(c3.size.box, fill: :pink, t: c3.pin.point)
    # |> Scenic.Primitives.rectangle(c4.size.box, fill: :purple, t: c4.pin.point)
  end

  def header_frame(frame) do
    frame
    |> Frame.shrink(0.1, :top)
  end
end
