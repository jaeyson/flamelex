defmodule Flamelex.GUI.Components.NeoHyperCard do
  use Scenic.Component
  require Logger

  def validate(%{frame: _frame, state: _s} = data) do
    {:ok, data}
  end

  def init(scene, args, opts) do
    init_graph = render(Scenic.Graph.build(), args)

    init_scene =
      scene
      |> assign(graph: init_graph)
      |> assign(frame: args.frame)
      |> assign(state: args.state)
      |> push_graph(init_graph)

    {:ok, init_scene}
  end

  def render(graph, %{frame: frame, state: %Memelex.TidBit{} = t}) do
    graph
    |> Scenic.Primitives.group(fn graph ->
      graph
      |> Scenic.Primitives.rect(frame.size.box, fill: :yellow, stroke: {2, :blue})
      |> Scenic.Primitives.text(t.title,
                  # font: font.name,
                  font_size: 20,
                  fill: :black,
                  translate: {0, 72}
                  # translate: {5, font.ascent}
               )
      # |> render_background(args.frame, args.state)
      # |> render_header(args.frame, args.state)
      # |> render_body(args.frame, args.state)
   end, [
  #     id: {:hypercard, args.state.uuid},
      translate: frame.pin.point
   ])
  end


  # next 2 todos for todo list

  # - handle "new tidbit savbed" event and auto-refresh
  # - allow scrolling within the vertical list
  # - add priority/sorting within the list and make them clickable

end
