defmodule Flamelex.GUI.Layers.Layer2.Renderizer do

  # NOTE eventually we should not re-draw everything from scratch each time, but for now,
  # since this component rarely updates, it's fine...

  # I think if I put an :id on the MenuBar component, when we redraw we might start to
  # get errors like "couldn't register a process, name taken" etc, because Scenic doesn't always
  # exit the other process before starting this one (and why should it) - if I really
  # wanted to register that component for some reason, then I would have to change this
  # renderizer to follow the pattern of not simply re-rendering, but checking if that component
  # exists, and if it does exist modifying it in place

  def render(%Widgex.Frame{} = layer_f, layer_state) do
    graph =
      Scenic.Graph.build()
      |> ScenicWidgets.MenuBar.add_to_graph(
        %{
          frame: calc_menubar_frame(layer_f, layer_state),
          menu_map: layer_state.menu_map
        }
      )

    graph
  end

  def calc_menubar_frame(layer_f, %{menubar: %{height: menubar_h}}) do
    layer_f
    |> Widgex.Frame.v_split(px: menubar_h)
    |> List.first()
  end
end
