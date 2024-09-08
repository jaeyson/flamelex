defmodule Flamelex.GUI.Component.TODOdetails do
  use Scenic.Component

  def validate(
        %{
          frame: %Widgex.Frame{} = _f,
          state: %Memelex.TidBit{} = _t
        } = data
      ) do
    # Logger.debug "#{__MODULE__} accepted params: #{inspect data}"
    {:ok, data}
  end

  def init(scene, args, opts) do
    # init_graph = old_render(Scenic.Graph.build(), args)
    init_graph = render(Scenic.Graph.build(), args)

    init_scene =
      scene
      |> assign(graph: init_graph)
      |> assign(frame: args.frame)
      # |> assign(theme: theme)
      |> assign(state: args.state)
      |> push_graph(init_graph)

    # Flamelex.Lib.Utils.PubSub.subscribe(topic: :radix_state_change)

    {:ok, init_scene}
  end

  def render(graph, %{
        frame: %Widgex.Frame{} = f,
        state: %Memelex.TidBit{} = t
      }) do
    # todo_widgets =
    #   args.state.list
    #   |> Enum.map(fn t ->
    #     {NeoHyperCard, %{tidbit: t}}
    #   end)

    panel_h = 300

    blocks = [
      {ScenicWidgets.FrameBox,
       %{frame: Widgex.Frame.new(%{size: {f.size.width, panel_h}, pin: {0, 0}})}},
      {ScenicWidgets.FrameBox,
       %{frame: Widgex.Frame.new(%{size: {f.size.width, panel_h}, pin: {20, panel_h}})}},
      {ScenicWidgets.FrameBox,
       %{frame: Widgex.Frame.new(%{size: {f.size.width, panel_h}, pin: {40, 2 * panel_h}})}},
      {ScenicWidgets.FrameBox,
       %{frame: Widgex.Frame.new(%{size: {f.size.width, panel_h}, pin: {60, 3 * panel_h}})}}
    ]

    graph
    |> Scenic.Primitives.group(
      fn graph ->
        graph
        |> ScenicWidgets.VerticalList.add_to_graph(%{frame: f, items: blocks})
      end,
      translate: f.pin.point
    )
  end

  def old_render(graph, %{
        frame: %Widgex.Frame{} = f,
        state: %Memelex.TidBit{} = t
      }) do
    graph
    |> render_raw_tidbit(f, t)
    |> render_tools(f)
  end

  def render_raw_tidbit(graph, frame, %Memelex.TidBit{} = t) do
    graph
    |> Scenic.Primitives.group(
      fn graph ->
        graph
        # |> Widgex.Frame.draw_guidewires(f, color: :purple)
        |> Scenic.Primitives.text("#{prettify_map(t)}",
          font: :ibm_plex_mono,
          font_size: 24,
          fill: :white,
          translate: {20, 50}
        )
      end,
      translate: frame.pin.point
    )
  end

  @spacing 180
  def render_tools(graph, %Widgex.Frame{} = f) do
    graph
    |> Scenic.Primitives.group(
      fn graph ->
        graph
        |> Scenic.Components.button("Lower priority", id: :lower_priority, t: {10, 10})
        |> Scenic.Components.button("Higher priority",
          id: :higher_priority,
          t: {10 + @spacing, 10}
        )
        |> Scenic.Components.button("Add Due date",
          id: :sample_btn_id,
          t: {10 + 2 * @spacing, 10}
        )
        |> Scenic.Components.button("Consequences",
          id: :sample_btn_id,
          t: {10 + 3 * @spacing, 10}
        )
        ## next row
        |> Scenic.Components.button("Create sub-task", id: :sample_btn_id, t: {10, 60})
        |> Scenic.Components.button("Blockers", id: :sample_btn_id, t: {10 + 1 * @spacing, 60})
        |> Scenic.Components.button("Req'd resources",
          id: :sample_btn_id,
          t: {10 + 2 * @spacing, 60}
        )
        |> Scenic.Components.button("Apply label",
          id: :sample_btn_id,
          t: {10 + 3 * @spacing, 60}
        )
        ## next row
        |> Scenic.Components.button("Last movement", id: :sample_btn_id, t: {10, 110})
        |> Scenic.Components.button("Next action", id: :sample_btn_id, t: {10 + 1 * @spacing, 110})
      end,
      # translate: {20, f.size.height - 200}
      translate: {f.pin.x + 20, f.pin.y + f.size.height - 200}
    )
    # close button
    |> Scenic.Components.button("Close", id: :close, t: {450, 20})
  end

  def handle_event({:click, :higher_priority}, _from, scene) do
    scene.assigns.state
    |> Memelex.My.Wiki.update(%{priority: :higher})

    {:noreply, scene}
  end

  def handle_event({:click, :close}, _from, scene) do
    Flamelex.Fluxus.action({[app: __MODULE__], :close_todo})
    {:noreply, scene}
  end

  def handle_event({:click, btn}, _from, scene) do
    IO.puts("Sample button was clicked in HANDLE EVENT! #{inspect(btn)}")
    {:noreply, scene}
  end

  def prettify_map(map) when is_map(map) do
    map
    |> Inspect.Algebra.to_doc(%Inspect.Opts{pretty: true, width: 80})
    |> Inspect.Algebra.format(80)
    |> IO.iodata_to_binary()
  end
end
