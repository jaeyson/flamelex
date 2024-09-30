defmodule Flamelex.GUI.Component.HighCouncil.Render do
  @moduledoc """
  This module serves as a container for very complex render functions
  to avoid cluttering up the components.
  """
  alias Widgex.Frame
  alias Widgex.Frame.Grid
  alias Flamelex.GUI.Component.HighCouncil.State

  def go(%Frame{} = frame, %State{} = state) do
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

    Scenic.Graph.build()
    |> Scenic.Primitives.group(fn graph ->
      graph
      |> Flamelex.GUI.Utils.Draw.background(frame, :orange)
      |> render_title(banner_frame, %{})
      |> render_agent_card(t3, %{})
      |> render_tools(footer_frame)

      # |> maybe_render_new_agent_modal(t2, %{})
    end)
  end

  def render_title(graph, %Widgex.Frame{} = f, _args) do
    graph
    |> Scenic.Primitives.rectangle(f.size.box, fill: :green, t: f.pin.point)
    |> ScenicWidgets.Markup.Header1.draw(%{
      frame: f,
      text: "High Council",
      color: :white
      # debug?: true
    })
  end

  def render_agent_card(graph, %Widgex.Frame{} = f, args) do
    graph
    |> Scenic.Primitives.rectangle(f.size.box, fill: :blue, t: f.pin.point)
    |> ScenicWidgets.Markup.Header1.draw(%{
      frame: f,
      text: "Agent: Maxwell",
      color: :white
    })

    # |> Scenic.Primitives.text("Agent Card",
    #   font_size: 20,
    #   translate: {f.pin.x + 10, f.pin.y + 10},
    #   fill: :black
    # )
  end

  def render_tools(graph, %Widgex.Frame{} = f) do
    graph
    |> Flamelex.GUI.Utils.Draw.background(f, :grey)
    # |> Flamelex.GUI.Utils.Draw.button(%{
    #   frame: f,
    #   text: "New Agent",
    #   color: :white,
    #   background_color: :blue,
    #   on_click: &handle_new_agent_click/0
    # })
    |> Scenic.Components.button("New agent",
      id: :new_agent,
      translate: Widgex.Frame.center(f).point
    )
  end
end
