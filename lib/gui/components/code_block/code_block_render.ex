defmodule Flamelex.GUI.Component.CodeBlock.Render do
  @moduledoc """
  Functions to render the %Scenic.Graph{} for CodeBlock component.
  """

  alias Flamelex.GUI.Component.CodeBlock.State
  alias Flamelex.GUI.Utils.Draw
  alias Scenic.Graph
  alias Scenic.Primitives
  alias Widgex.Frame

  @radius 14
  @header_height 60
  @margin 10

  def go(%Frame{} = frame, %State{title: title, text: text} = _state) do
    Graph.build()
    |> Primitives.group(fn graph ->
      # Draw the rounded rectangle background
      graph =
        graph
        |> Primitives.rounded_rectangle(
          {frame.size.width, frame.size.height, @radius},
          fill: :white,
          stroke: {1, :light_gray},
          translate: frame.pin.point
        )

      # Draw the grey bar at the top with rounded top corners
      graph =
        graph
        |> Primitives.rounded_rectangle(
          {frame.size.width, @header_height, @radius},
          fill: :light_gray,
          translate: frame.pin.point
        )
        |> Primitives.rectangle(
          {frame.size.width, @header_height / 2},
          fill: :light_gray,
          translate: {frame.pin.x, frame.pin.y + @header_height / 2}
        )

      # Draw the title centered in the grey bar
      graph =
        graph
        |> Primitives.text(
          title,
          font_size: 24,
          fill: :black,
          text_align: :center,
          text_base: :middle,
          translate: {
            frame.pin.x + frame.size.width / 2,
            frame.pin.y + @header_height / 2
          }
        )

      # Render the text in the main body with margin
      graph =
        graph
        |> Primitives.text(
          text,
          font_size: 16,
          fill: :black,
          # font: :mono,
          text_align: :left,
          text_base: :top,
          translate: {
            frame.pin.x + @margin,
            frame.pin.y + @header_height + @margin
          }
        )

      graph
    end)
  end
end
