defmodule Flamelex.GUI.Layers.NeoLayer01 do
  use Widgex.Layer
  alias Flamelex.GUI.Components.NeoHyperCard, as: HyperCard

  require Logger

  def cast_rdx_to_layer_state(%{
    menubar: %{height: menubar_h},
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
      todos: todo_list,
      menubar: %{height: menubar_h}
    }
  end

  def cast_rdx_to_layer_state(%{
    menubar: %{height: menubar_h},
    layers: %{
      one: %{
        active_app: nil
      }
    }
  }) do
    %{menubar: %{height: menubar_h}}
  end

  # NOTE having an intermediate component which listens to memelex events vs radix state holding everything...
  # I'm just gonna go all in on radix state & see where that breaks - it's simpler & I _need_ to start making actual progress on this project...

  def render(full_window_frame, %{
    layout: :full_screen,
    active_app: :todo_list,
    todos: todo_list
  } = layer_state) do

    # we can't use the entire screen when the menubar is visible
    app_frame = calc_app_frame(full_window_frame, layer_state)

    todo_widgets =
      todo_list
      |> Enum.map(fn t ->
        {HyperCard, %{frame: nil, state: t}}
      end)

    graph =
      Scenic.Graph.build()
      # |> Scenic.Primitives.rectangle(app_frame.size.box, fill: :red)
      # |> Frame.draw_guidewires(app_frame)
      |> Flamelex.GUI.Component.TODOlist.add_to_graph(%{frame: app_frame, state: %{items: todo_widgets}})
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

  def calc_app_frame(full_window_frame, %{menubar: %{height: menubar_h}}) do
    [_menubar_frame, app_frame] =
      Frame.v_split(full_window_frame, px: menubar_h)

    app_frame
  end
end
