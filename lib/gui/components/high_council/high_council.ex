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
  alias Widgex.Frame.Grid

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

  # Default render function
  def render(%Frame{} = frame, %State{} = state) do
    grid =
      Grid.new(frame)
      |> Grid.rows([0.10, 0.35, 0.35, 0.20])
      |> Grid.columns([1.0 / 3.0, 1.0 / 3.0, 1.0 / 3.0])
      |> Grid.row_gap(0)
      |> Grid.column_gap(0)
      |> Grid.define_areas(%{
        banner: {0, 0, 1, 3},
        footer: {3, 0, 1, 3},
        tile1: {1, 0, 1, 1},
        tile2: {1, 1, 1, 1},
        tile3: {1, 2, 1, 1},
        tile4: {2, 0, 1, 1},
        tile5: {2, 1, 1, 1},
        tile6: {2, 2, 1, 1}
      })

    # Calculate the frames
    cell_frames = Grid.calculate(grid)

    # Retrieve frames for banner and footer
    banner_frame = Grid.area_frame(grid, cell_frames, :banner)
    footer_frame = Grid.area_frame(grid, cell_frames, :footer)
    t2 = Grid.area_frame(grid, cell_frames, :tile2)
    t3 = Grid.area_frame(grid, cell_frames, :tile3)

    # Retrieve frames for tiles
    # tile_frames =
    #   for tile <- [:tile1, :tile2, :tile3, :tile4, :tile5, :tile6], into: %{} do
    #     {tile, Grid.area_frame(grid, cell_frames, tile)}
    #   end

    Graph.build()
    |> Scenic.Primitives.rectangle(frame.size.box, fill: :orange, t: frame.pin.point)
    |> Scenic.Primitives.rectangle(banner_frame.size.box,
      fill: :green,
      t: banner_frame.pin.point
    )
    |> ScenicWidgets.Markup.Header1.draw(%{
      frame: banner_frame,
      text: "High Council",
      debug?: true
    })
    # |> Scenic.Primitives.rectangle(c1.size.box, fill: :blue, t: c1.pin.point)
    # |> Scenic.Primitives.rectangle(footer_frame.size.box,
    #   fill: :silver,
    #   t: footer_frame.pin.point
    # )
    # |> Scenic.Primitives.rectangle(t2.size.box,
    #   fill: :gold,
    #   t: t2.pin.point
    # )
    |> render_agent_card(t3, %{})

    # |> Scenic.Primitives.rectangle(c2.size.box, fill: :grey, t: c2.pin.point)
    # |> Scenic.Primitives.rectangle(c3.size.box, fill: :pink, t: c3.pin.point)
    # |> Scenic.Primitives.rectangle(c4.size.box, fill: :purple, t: c4.pin.point)
  end

  def render_agent_card(graph, %Widgex.Frame{} = f, args) do
    graph
    |> Scenic.Primitives.rectangle(f.size.box, fill: :blue, t: f.pin.point)
    |> ScenicWidgets.Markup.Header1.draw(%{
      frame: f,
      text: "Agent: Maxwell",
      color: :white,
      debug?: true
    })

    # |> Scenic.Primitives.text("Agent Card",
    #   font_size: 20,
    #   translate: {f.pin.x + 10, f.pin.y + 10},
    #   fill: :black
    # )
  end

  # def header_frame(frame) do
  #   frame
  #   |> Frame.shrink(0.1, :top)
  # end
end
