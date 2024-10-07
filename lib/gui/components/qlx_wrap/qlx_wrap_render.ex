# defmodule Flamelex.GUI.Component.QlxWrap.Render do
#   alias Flamelex.GUI.Component.QlxWrap

#   def go(%Widgex.Frame{} = frame, %QlxWrap.State{} = state) do
#     # TODO this is hacky but it works for now, eventually we should do something more sophisticated
#     buf_ref = hd(state.buffers)

#     Scenic.Graph.build()
#     |> Quillex.GUI.Buffer.draw(frame, buf_ref)
#   end
# end
