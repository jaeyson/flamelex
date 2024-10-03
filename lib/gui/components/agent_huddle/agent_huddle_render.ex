defmodule Flamelex.GUI.Component.AgentHuddle.Render do
  alias Flamelex.GUI.Component.AgentHuddle.State
  alias Flamelex.GUI.Utils.Draw

  def go(%Widgex.Frame{} = f, %State{} = state) do
    Scenic.Graph.build()
    |> Scenic.Primitives.group(
      fn graph ->
        graph
        |> Draw.background(f, :rebecca_purple)
        |> Widgex.Frame.draw_guidewires(f)
        |> Scenic.Primitives.text("Flamelex.GUI.Component.AgentHuddle",
          font_size: 24,
          translate: {f.size.width / 2, f.size.height / 2}
        )
      end,
      translate: f.pin.point
    )
  end
end
