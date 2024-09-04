defmodule Flamelex.GUI.Layers.NeoLayer01 do
  use Widgex.Layer
  alias Flamelex.GUI.Components.NeoHyperCard, as: HyperCard

  require Logger

  def cast_rdx_to_layer_state(%{
    layers: %{
      one: %{
        layout: :full_screen,
        active_app: :todo_list,
        todos: todo_list
      }
    }
  }) do
    %{
      layout: :full_screen,
      active_app: :todo_list,
      todos: todo_list
    }
  end

  def cast_rdx_to_layer_state(%{
    layers: %{
      one: %{
        active_app: nil
      }
    }
  }) do
    %{}
  end

  # NOTE having an intermediate component which listens to memelex events vs radix state holding everything...
  # I'm just gonna go all in on radix state & see where that breaks - it's simpler & I _need_ to start making actual progress on this project...

  def render(frame, %{
    layout: :full_screen,
    active_app: :todo_list,
    todos: todo_list
  } = _layer_state) do

    todo_widgets =
      todo_list
      |> Enum.map(fn t ->
        {HyperCard, %{frame: nil, state: t}}
      end)

    graph =
      Scenic.Graph.build()
      |> Flamelex.GUI.Component.TODOlist.add_to_graph(%{frame: frame, state: %{items: todo_widgets}})
      # |> Scenic.Primitives.rectangle(frame.size.box, fill: :red)
      # |> ScenicWidgets.VerticalList.add_to_graph(%{frame: frame, items: todo_widgets})

    {:ok, graph}
  end

  # eventually make this go away but for now just render a blue box
  def render(frame, %{} = _layer_state) do
    Logger.warning "Rendering layer 1 when the active app was set to nil..."

    graph =
      Scenic.Graph.build()
      |> Scenic.Primitives.rectangle(frame.size.box, fill: :blue)

    {:ok, graph}
  end
end
