defmodule Flamelex.GUI.Layers.Layer01.Render do
  def render(frame, state) do
    Scenic.Graph.build()
    |> render(frame, state)
  end

  def render(graph, _frame, %{active_apps: []} = _layer_state) do
    {:ok, graph}
  end

  def render(graph, frame, %{layout: :full_screen, active_apps: [app | _rest]}) do
    # for full screen just let the first app take up the whole frame
    Wormhole.capture(fn ->
      graph
      |> app.add_to_graph(%{frame: frame})
    end)
  end

  def render(graph, frame, %{layout: {Widgex.Frame.Grid}, active_apps: [app | _rest]}) do
    # for full screen just let the first app take up the whole frame
    Wormhole.capture(fn ->
      graph
      |> app.add_to_graph(%{frame: frame})
    end)
  end

  def render(graph, frame, %{layout: :split_screen, active_apps: [app1, app2]}) do
    Wormhole.capture(fn ->
      [left_frame, right_frame] = Widgex.Frame.h_split(frame)

      graph
      |> app1.add_to_graph(%{frame: left_frame})
      |> app2.add_to_graph(%{frame: right_frame})
    end)
  end

  def render(_f, state) do
    Logger.error("Unrecognised Layer State:\n\n#{prettify_map(state)}")
    {:error, "Unrecognised Layer State"}
  end

  defp prettify_map(map) when is_map(map) do
    map
    |> Inspect.Algebra.to_doc(%Inspect.Opts{pretty: true, width: 80})
    |> Inspect.Algebra.format(80)
    |> IO.iodata_to_binary()
  end

  def re_render(
        scene,
        %{apps: %{qlx_wrap: %{buffers: []}}} = rdx_state,
        {:project_view, project_dir}
      ) do
    # TODO maybe re-render on existing graph but for now this is fine
    grid =
      Widgex.Frame.Grid.new(scene.assigns.frame)
      # Single row taking 100% of the height
      |> Widgex.Frame.Grid.rows([1.0])
      # Left column takes 28% width, right column takes 72% width
      |> Widgex.Frame.Grid.columns([0.27, 0.73])
      |> Widgex.Frame.Grid.define_areas(%{
        left_half: {0, 0, 1, 1},
        right_half: {0, 1, 1, 1}
      })

    cell_frames = Widgex.Frame.Grid.calculate(grid)
    left_frame = Widgex.Frame.Grid.area_frame(grid, cell_frames, :left_half)
    right_frame = Widgex.Frame.Grid.area_frame(grid, cell_frames, :right_half)

    new_graph =
      Scenic.Graph.build()
      |> Flamelex.GUI.Component.FileExplorer.add_to_graph(%{
        frame: left_frame,
        state: %{open_proj: project_dir}
      })

    scene
    |> Scenic.Scene.assign(graph: new_graph)
    |> Scenic.Scene.push_graph(new_graph)
  end

  def re_render(
        scene,
        %{apps: %{qlx_wrap: %{buffers: [b | _rest]}}} = rdx_state,
        {:project_view, project_dir}
      ) do
    # TODO maybe re-render on existing graph but for now this is fine
    grid =
      Widgex.Frame.Grid.new(scene.assigns.frame)
      # Single row taking 100% of the height
      |> Widgex.Frame.Grid.rows([1.0])
      # Left column takes 28% width, right column takes 72% width
      |> Widgex.Frame.Grid.columns([0.27, 0.73])
      |> Widgex.Frame.Grid.define_areas(%{
        left_half: {0, 0, 1, 1},
        right_half: {0, 1, 1, 1}
      })

    cell_frames = Widgex.Frame.Grid.calculate(grid)
    left_frame = Widgex.Frame.Grid.area_frame(grid, cell_frames, :left_half)
    right_frame = Widgex.Frame.Grid.area_frame(grid, cell_frames, :right_half)

    new_graph =
      Scenic.Graph.build()
      |> Flamelex.GUI.Component.FileExplorer.add_to_graph(%{
        frame: left_frame,
        state: %{open_proj: project_dir}
      })
      |> Flamelex.GUI.Component.QlxWrap.add_to_graph(%{
        frame: right_frame
      })

    scene
    |> Scenic.Scene.assign(graph: new_graph)
    |> Scenic.Scene.push_graph(new_graph)
  end
end
