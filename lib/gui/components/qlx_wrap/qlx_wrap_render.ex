defmodule Flamelex.GUI.Component.QlxWrap.Render do
  alias Flamelex.GUI.Component.QlxWrap
  alias Quillex.GUI.Components.Buffer

  def go(%Widgex.Frame{} = frame, %QlxWrap.State{} = state) do
    # TODO this is hacky but it works for now, eventually we should do something more sophisticated
    buf_ref = hd(state.buffers)

    graph =
      Scenic.Graph.build()
      |> Buffer.add_to_graph(%{frame: frame, buf_ref: buf_ref})
  end
end
