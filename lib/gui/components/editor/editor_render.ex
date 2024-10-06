defmodule Flamelex.GUI.Component.Editor.Render do
  @moduledoc """
  Functions to render the %Scenic.Graph{} for the Editor component.
  """

  alias Flamelex.GUI.Component.Editor.State
  alias Flamelex.GUI.Utils.Draw
  alias Scenic.Graph
  alias Scenic.Primitives
  # Add this alias
  alias ScenicWidgets.TextPad.CursorCaret

  def go(%Widgex.Frame{} = frame, %State{} = state) do
    # text = @no_limits_to_tomorrow
    # font_size = 24
    # font_name = :ibm_plex_mono

    # # TODO this is a little cheeky, should pass it through via the state somehow...
    # font_metrics = Flamelex.Fluxus.RadixStore.get().fonts.ibm_plex_mono.metrics
    # ascent = FontMetrics.ascent(font_size, font_metrics)

    # font = %{
    #   name: font_name,
    #   size: font_size,
    #   metrics: font_metrics
    # }

    # colors = @cauldron

    buf_ref = hd(state.buffers)

    # def add_component_to_graph(graph, component_module, component_pid, opts) do
    #   graph
    #   |> Scenic.Primitives.group(fn g ->
    #     g |> component_module.add_to_graph(%{pid: component_pid}, opts)
    #   end)
    # end

    # |> MyApp.BufferServer.add_to_graph(%{pid: buf.pid}, [])

    # TODO here is where we should add a Quillex.GUI.Buffer.add_to_graph

    graph =
      Graph.build()
      |> Quillex.GUI.Buffer.draw(frame, buf_ref)

    # |> Primitives.group(
    #   fn graph ->
    #     graph
    #     |> Draw.background(frame, colors.slate)
    #     |> Primitives.text(
    #       text,
    #       font_size: font_size,
    #       font: font_name,
    #       fill: colors.text,
    #       translate: {10, ascent + 10}
    #       # translate: {10, 10}
    #     )
    #     |> Flamelex.GUI.Component.Editor.CursorCaret.add_to_graph(
    #       %{
    #         buffer_uuid: buf.uuid,
    #         coords: {10, 10},
    #         height: font_size,
    #         mode: :cursor,
    #         font: font
    #       },
    #       id: :cursor
    #     )
    #   end,
    #   translate: frame.pin.point
    # )

    graph
  end
end
