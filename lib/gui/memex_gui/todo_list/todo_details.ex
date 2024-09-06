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
    init_graph = render(Scenic.Graph.build(), args)

    init_scene =
      scene
      |> assign(graph: init_graph)
      |> assign(frame: args.frame)
      # |> assign(theme: theme)
      |> assign(state: args.state)
      |> push_graph(init_graph)

    # Flamelex.Lib.Utils.PubSub.subscribe(topic: :radix_state_change)

    {:ok, scene}
  end

  def render(graph, %{
        frame: %Widgex.Frame{} = f,
        state: %Memelex.TidBit{} = t
      }) do
    graph
    |> Scenic.Primitives.group(
      fn graph ->
        graph
        |> Widgex.Frame.draw_guidewires(f, color: :purple)
      end,
      translate: f.pin.point
    )
  end
end
