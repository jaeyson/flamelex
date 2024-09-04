defmodule Flamelex.GUI.Component.TODOlist do
  @moduledoc """
  A GUI component for managing my TODO list.
  """
  use Scenic.Component
  alias Widgex.Structs.Frame


  def validate(%{frame: %Frame{} = _f, state: _state} = data) do
    # Logger.debug "#{__MODULE__} accepted params: #{inspect data}"
    {:ok, data}
  end

  def init(scene, args, opts) do
    init_graph = init_render(args)

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

  def init_render(args) do
    Scenic.Graph.build()
    |> ScenicWidgets.VerticalList.add_to_graph(%{frame: args.frame, items: args.state.items})
  end
end
