defmodule Flamelex.GUI.Component.Kommander.Render do
  alias Flamelex.GUI.Component.Kommander

  @prompt %{
    color: :ghost_white,
    size: 18,
    margin: 12
  }

  @kommander_prompt :k_prompt
  @kommander_textbox :k_textbox
  @kommander_buffer_pane :k_buf_pane

  def render(
    %Scenic.Graph{} = graph,
    %Scenic.Scene{} = scene,
    %Widgex.Frame{} = frame,
    %Flamelex.GUI.Component.Kommander.State{} = state
  ) do
    graph
    |> Scenic.Primitives.group(
      fn graph ->
        graph
        |> ScenicWidgets.FrameBox.draw(%{frame: frame, fill: :rebecca_purple})
        |> draw_command_prompt(frame)
        |> draw_textbox(frame, state)
      end
    )
  end

  defp draw_command_prompt(graph, frame) do
    case Scenic.Graph.get(graph, @kommander_prompt) do
      [] ->
        # NOTE: The y_offset
        #      ------------
        #      From the top-left position of the box, the command prompt
        #      y-offset. (height - prompt.size) is how much bigger the
        #      buffer is than the command prompt, so it gives us the extra
        #      space - we divide this by 2 to get how much extra space we
        #      need to add, to the reference y coordinate, to center the
        #      command prompt inside the buffer
        y_offset = frame.pin.y + (frame.size.height - @prompt.size) / 2

        # NOTE: How Scenic draws triangles
        #      --------------------------
        #      Scenic uses 3 points to draw a triangle, which look like this:
        #
        #           x - point1
        #           |\
        #           | \ x - point2 (apex of triangle)
        #           | /
        #           |/
        #           x - point3
        point1 = {@prompt.margin, y_offset}
        point2 = {@prompt.margin + prompt_width(@prompt.size), y_offset + @prompt.size / 2}
        point3 = {@prompt.margin, y_offset + @prompt.size}

        graph
        |> Scenic.Primitives.triangle({point1, point2, point3}, id: @kommander_prompt, fill: @prompt.color)

      _primitive ->
        # nothing to change...
        graph
    end
  end

  defp draw_textbox(graph, frame, state) do
    case Scenic.Graph.get(graph, :prompt_triangle) do
      [] ->
        textbox_frame = calc_textbox_frame(frame)

        graph
        |> Scenic.Primitives.group(
          fn graph ->
            graph
            # |> ScenicWidgets.FrameBox.draw(%{frame: textbox_frame, border: :black})
            |> Quillex.GUI.Components.BufferPane.add_to_graph(%{
              frame: textbox_frame,
              buf_ref: state.buf_ref,
              font: state.font
            },
              id: @kommander_buffer_pane,
              translate: textbox_frame.pin.point
            )

          end,
          id: @kommander_textbox)

      _primitive ->
        # nothing to change...
        graph
    end
  end

  def calc_textbox_frame(%Widgex.Frame{
        pin: %{x: cmd_buf_top_left_x, y: cmd_buf_top_left_y},
        size: %{height: cmd_buf_height, width: cmd_buf_width}
      }) do
    total_prompt_width = prompt_width(@prompt.size) + 2 * @prompt.margin

    textbox_coords = {
      # this is the x coord for the top-left corner of the Textbox - take the CommandBuffer top_left_x and add some margin
      cmd_buf_top_left_x + total_prompt_width,
      # this is the y coord for the top-left corner of the Textbox - plus 5 to move the box down, because remember we reference from top-left corner
      cmd_buf_top_left_y + 5
    }

    textbox_width = cmd_buf_width - total_prompt_width - @prompt.margin
    textbox_dimens = {textbox_width, cmd_buf_height - 10}

    Widgex.Frame.new(
      pin: textbox_coords,
      size: textbox_dimens
    )
  end

  def prompt_width(prompt_size) do
    prompt_size * 0.67
  end
end
