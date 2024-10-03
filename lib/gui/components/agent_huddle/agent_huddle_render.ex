defmodule Flamelex.GUI.Component.AgentHuddle.Render do
  alias Flamelex.GUI.Component.AgentHuddle.State
  alias Flamelex.GUI.Utils.Draw
  alias Widgex.Frame
  alias Widgex.Frame.Grid
  alias Scenic.Graph
  alias Scenic.Primitives

  def go(%Frame{} = frame, %State{} = state) do
    # Define a grid that splits the frame into two equal columns
    grid =
      Grid.new(frame)
      # Single row taking 100% of the height
      |> Grid.rows([1.0])
      # Two columns, each 50% of the width
      |> Grid.columns([0.5, 0.5])
      |> Grid.define_areas(%{
        left_half: {0, 0, 1, 1},
        right_half: {0, 1, 1, 1}
      })

    # Calculate the frames for each grid area
    cell_frames = Grid.calculate(grid)
    left_frame = Grid.area_frame(grid, cell_frames, :left_half)
    right_frame = Grid.area_frame(grid, cell_frames, :right_half)

    # Build the graph with the new layout
    graph =
      Graph.build()
      |> Primitives.group(
        fn graph ->
          graph
          |> Draw.background(frame, :rebecca_purple)
          |> Widgex.Frame.draw_guidewires(frame)
          |> render_left_half(left_frame, state)
          |> render_right_half(right_frame, state)
        end,
        translate: frame.pin.point
      )

    graph
  end

  # Render content in the left half
  defp render_left_half(graph, %Frame{} = frame, %State{} = _state) do
    graph
    |> Primitives.text("Left Half",
      font_size: 24,
      fill: :white,
      translate: {frame.pin.x + 10, frame.pin.y + 10}
      # translate: {frame.size.width / 2, frame.size.height / 2}
      # translate: frame.pin.point
    )
  end

  # Render content in the right half
  defp render_right_half(graph, %Frame{} = frame, %State{} = _state) do
    graph
    |> Primitives.text("Right Half",
      font_size: 24,
      fill: :white,
      translate: {frame.pin.x + 10, frame.pin.y + 10}
      # translate: {frame.size.width / 2, frame.size.height / 2}
      # translate: frame.pin.point
    )
  end
end
