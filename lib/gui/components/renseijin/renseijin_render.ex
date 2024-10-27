defmodule Flamelex.GUI.Components.Renseijin.Rend do
  @doc """
  The unique function which renders the Renseijin component.
  """

  alias Flamelex.GUI.Components.Renseijin

  # it's called `er` because the module is Rend,
  # to together it's Rend.er
  @spec er(Widgex.Frame.t(), Renseijin.State.t()) :: Scenic.Graph.t()
  def er(%Widgex.Frame{} = frame, %Renseijin.State{} = state) do
    Scenic.Graph.build()
    |> Renseijin.Utils.draw_background(frame, state)
    |> Scenic.Primitives.group(
      fn graph ->
        graph
        |> Renseijin.Utils.draw_circles(frame, state)
        |> Renseijin.Utils.draw_triangles(frame, state)
        |> Renseijin.Utils.draw_taijitu(frame, state)
        |> Renseijin.Utils.draw_hexagons(frame, state)

        # |> Utils.draw_squares(frame, state)
        # |> Utils.draw_pyramids(frame, state)
      end,
      id: __MODULE__,
      translate: Widgex.Frame.center(frame).point
    )
    |> Scenic.Graph.modify(:scissor, frame.size.box)
  end
end
