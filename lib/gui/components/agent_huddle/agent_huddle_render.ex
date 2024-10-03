defmodule Flamelex.GUI.Component.AgentHuddle.Render do
  alias Flamelex.GUI.Component.AgentHuddle.State
  alias Flamelex.GUI.Utils.Draw
  alias Widgex.Frame
  alias Widgex.Frame.Grid
  alias Scenic.Graph
  alias Scenic.Primitives
  alias Flamelex.GUI.Component.CodeBlock

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
          # |> Draw.background(frame, :rebecca_purple)
          # |> Widgex.Frame.draw_guidewires(frame)
          |> render_left_half(left_frame, state)
          |> render_right_half(right_frame, state)
        end
        # translate: frame.pin.point
      )

    graph
  end

  # Render content in the left half
  defp render_left_half(graph, %Frame{} = frame, %State{} = _state) do
    # 1. Draw a background over the left half
    # graph =
    #   graph
    #   |> Draw.background(frame, :dark_blue)
    #   |> Widgex.Frame.draw_guidewires(frame)

    # 3. Define a grid within the inner_frame
    grid =
      Grid.new(frame)
      |> Grid.rows([0.04, 0.92, 0.04])
      |> Grid.columns([0.04, 0.92, 0.04])
      |> Grid.define_areas(%{
        editor_area: {1, 1, 1, 1}
      })

    # Calculate the frames for the grid areas
    cell_frames = Grid.calculate(grid)
    editor_frame = Grid.area_frame(grid, cell_frames, :editor_area)

    # TODO there's some fuckiness with how frames get placed when
    # the outer frame is translated, I think we need to not include
    # the old pin in our Grid frames but it's complex, so hacking it for now

    # IO.inspect(frame, label: "f1")
    # IO.inspect(editor_frame, label: "f1")
    # 4. Render the editor placeholder in the editor_frame
    graph =
      graph
      # |> Primitives.group(fn graph ->
      #   # Optional: Draw background for the editor area
      #   graph
      #   # |> Draw.background(editor_frame, :white)
      #   # |> Scenic.Primitives.rect(editor_frame.size.box,
      #   #   fill: :dark_slate_grey
      #   #   # translate: editor_frame.pin.point
      #   # )
      |> CodeBlock.add_to_graph(%{frame: editor_frame})

    # |> Widgex.Frame.draw_guidewires(editor_frame)
    # |> Primitives.text("Editor Placeholder",
    #   font_size: 24,
    #   fill: :white
    #   # translate: {
    #   #   editor_frame.pin.x + editor_frame.size.width / 2,
    #   #   editor_frame.pin.y + editor_frame.size.height / 2
    #   # },
    #   # text_align: :center,
    #   # text_base: :middle
    # )
    # end)

    graph
  end

  # Render content in the right half
  defp render_right_half(graph, %Frame{} = frame, %State{} = _state) do
    graph
    |> Scenic.Primitives.rect(frame.size.box,
      fill: :black,
      translate: frame.pin.point
    )
    |> Primitives.text("Right Half",
      font_size: 24,
      fill: :white,
      translate: {frame.pin.x + 10, frame.pin.y + 10}
    )
  end
end
