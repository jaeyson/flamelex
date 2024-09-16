defmodule Flamelex.GUI.Components.NeoHyperCard do
  use Scenic.Component
  require Logger

  def validate(%{frame: %Widgex.Frame{} = _f, tidbit: %Memelex.TidBit{} = _t} = data) do
    {:ok, data}
  end

  def init(scene, args, opts) do
    init_graph = render(Scenic.Graph.build(), args)

    init_scene =
      scene
      |> assign(graph: init_graph)
      |> assign(frame: args.frame)
      |> assign(tidbit: args.tidbit)
      |> push_graph(init_graph)

    request_input(init_scene, [:cursor_button])

    {:ok, init_scene}
  end

  def render(graph, %{frame: frame, tidbit: %Memelex.TidBit{} = t}) do
    # need to anchor the new frame within this one, not re-use the same pin
    header_frame = Widgex.Frame.new(%{pin: {0, 0}, size: frame.size.box})

    fill_color = calc_fill_color(t)

    graph
    |> Scenic.Primitives.group(
      fn graph ->
        graph
        |> Scenic.Primitives.rect(frame.size.box, fill: fill_color, stroke: {2, :blue})
        |> ScenicWidgets.Markup.Header6.draw(header_frame, t.title)

        # |> Scenic.Primitives.text(t.title,
        #   # font: font.name,
        #   font_size: 20,
        #   fill: :black,
        #   translate: {0, 72}
        #   # translate: {5, font.ascent}
        # )

        # |> render_background(args.frame, args.state)
        # |> render_header(args.frame, args.state)
        # |> render_body(args.frame, args.state)
        # end)
      end,
      # #     id: {:hypercard, args.state.uuid},
      translate: frame.pin.point
      # NOTE - ADDING scissor here will cause it to not scissor!?!?!
      # scissor: frame.size.box
    )
  end

  def handle_input({:cursor_button, {:btn_left, 0, [], click_coords}}, _context, scene) do
    bounds = Scenic.Graph.bounds(scene.assigns.graph)

    if click_coords |> ScenicWidgets.Utils.inside?(bounds) do
      # IO.puts("CLICKCLIKC #{scene.assigns.tidbit.title}")
      cast_parent(scene, {:click, scene.assigns.tidbit})
    end

    {:noreply, scene}
  end

  def handle_input({:cursor_button, _otherwise}, _context, scene) do
    # Logger.debug "#{__MODULE__} ignoring input: #{inspect input}..."
    {:noreply, scene}
  end

  def calc_fill_color(%Memelex.TidBit{} = t) do
    cond do
      t.status in [:done, "done"] -> :green
      Memelex.My.TODOs.action_date_passed?(t) -> :red
      t.status in [:in_progress, "in_progress"] -> :green
      true -> :grey
    end
  end

  # next 2 todos for todo list

  # - handle "new tidbit savbed" event and auto-refresh
  # - allow scrolling within the vertical list
  # - add priority/sorting within the list and make them clickable
end
