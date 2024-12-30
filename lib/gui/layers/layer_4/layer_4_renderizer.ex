defmodule Flamelex.GUI.Layers.Layer4.Renderizer do
  use Scenic.Component
  alias Flamelex.GUI.Layers.Layer4
  require Logger

  @layer_4 :layer_4
  @kommander :kommander

  @kommander_height 50

  def render(
    %Scenic.Graph{} = graph,
    %Scenic.Scene{} = scene,
    %Widgex.Frame{} = frame,
    %Layer4.State{} = state
  ) do
    graph
    |> render_kommander(frame, state)
  end

  defp render_kommander(graph, frame, state) do
    case Scenic.Graph.get(graph, @kommander) do
      [] ->

        grid =
          Widgex.Frame.Grid.new(frame)
          |> Widgex.Frame.Grid.rows([0.9, 0.1])
          |> Widgex.Frame.Grid.columns([1.0])
          |> Widgex.Frame.Grid.define_areas(%{
            bottom_row: {1, 0, 1, 1} # Bottom row (row 1, column 0, spanning 1 row and 1 column)
          })

        cell_frames = Widgex.Frame.Grid.calculate(grid)

        kommander_frame = Widgex.Frame.Grid.area_frame(grid, cell_frames, :bottom_row)

        #     kommander_frame =
        #       ScenicWidgets.Core.Structs.Frame.new(
        #         pin: {0, vp_height - @kommander_height},
        #         # TODO why do we need this +1? Without it we see a think black stripe on the right-hand side
        #         size: {vp_width + 1, @kommander_height}
        #       )

        graph
        |> Scenic.Primitives.group(fn graph ->
            graph
            |> Scenic.Primitives.rect(kommander_frame.size.box, fill: :red, translate: kommander_frame.pin.point)
          end,
          id: @kommander,
          hidden: not state.kommander_active?
        )

      _primitive ->

        graph
        |> Scenic.Graph.modify(
          @kommander,
          &Scenic.Primitives.update_opts(&1, hidden: not state.kommander_active?)
        )
    end
  end

end
