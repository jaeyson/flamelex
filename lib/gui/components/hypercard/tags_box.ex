defmodule Memelex.GUI.Components.HyperCard.TagsBox do
  use Scenic.Component

  alias Scenic.Graph
  import Scenic.Primitives

  @default_font_size 16
  @default_padding 10
  @default_margin 10
  @default_bg_color :light_gray
  @default_text_color :black
  @default_border_color :black
  # Rounded corners for the tags
  @default_radius 4

  # This function draws tags and positions them in a grid-like format with proper spacing
  # def draw(%Scenic.Graph{} = graph, %Widgex.Frame{} = f, tags) when is_list(tags) do
  def draw(%Scenic.Graph{} = graph, tags) when is_list(tags) do
    # Set customizable options with fallbacks to defaults
    font_size = @default_font_size
    padding = @default_padding
    margin = @default_margin
    bg_color = @default_bg_color
    text_color = @default_text_color
    border_color = @default_border_color
    radius = @default_radius

    # Start coordinates
    x = 0
    y = 0

    # Initialize the position for rendering tags
    {initial_x, current_y} = {x, y}

    graph
    |> Scenic.Primitives.group(
      fn g ->
        Enum.reduce(tags, {g, initial_x, current_y}, fn tag, {graph, current_x, current_y} ->
          # Calculate the width of the tag based on its length and font size
          tag_width = String.length(tag) * font_size * 0.6
          tag_height = font_size + padding

          # If the tag would exceed the screen width, move to the next line
          # Adjust this to fit your desired width
          max_width = 600

          if current_x + tag_width + margin > max_width do
            # Reset x back to initial position
            current_x = initial_x
            # Move down to the next line
            current_y = current_y + tag_height + margin
          end

          # Draw the tag's background (with rounded corners)
          graph =
            graph
            |> rounded_rectangle({tag_width + padding, tag_height, 6},
              fill: bg_color,
              stroke: {1, border_color},
              radius: radius,
              translate: {current_x, current_y}
            )
            # Draw the tag text
            |> text(tag,
              fill: text_color,
              font_size: font_size,
              translate:
                {current_x + padding / 2, 12 + current_y + tag_height / 2 - font_size / 3}
            )

          # Move the x position forward for the next tag
          new_x = current_x + tag_width + padding + margin

          {graph, new_x, current_y}
        end)
        # Return the updated graph
        |> elem(0)
      end,
      translate: {5, 55}
      # translate: f.pin.point
    )
  end
end
