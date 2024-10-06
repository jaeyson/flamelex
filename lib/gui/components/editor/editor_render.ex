defmodule Flamelex.GUI.Component.Editor.Render do
  @moduledoc """
  Functions to render the %Scenic.Graph{} for the Editor component.
  """
  alias Flamelex.GUI.Component.Editor

  def go(%Widgex.Frame{} = frame, %Editor.State{} = state) do
    # TODO this is hacky but it works for now, eventually we should do something more sophisticated
    buf_ref = hd(state.buffers)

    Scenic.Graph.build()
    |> Quillex.GUI.Buffer.draw(frame, buf_ref)
  end
end
