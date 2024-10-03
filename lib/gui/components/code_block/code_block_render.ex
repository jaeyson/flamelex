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

  def go(%Frame{} = frame, %State{} = _state) do
    Graph.build()
    |> Primitives.group(fn graph ->
      # Draw the rounded rectangle background
      graph
      |> Primitives.rounded_rectangle(
        {frame.size.width, frame.size.height, @radius},
        fill: :white,
        stroke: {1, :light_gray},
        translate: frame.pin.point
      )
      # Draw the grey bar at the top
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
    end)
  end
end
