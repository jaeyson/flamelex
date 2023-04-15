defmodule Flamelex.GUI.Layers.LayerTwo do
  # NOTE: Something in here has to be about layouts
  # NOTE: Layer 2 is the MenuBar component

  @behaviour Flamelex.GUI.Layer.Behaviour

  @impl Flamelex.GUI.Layer.Behaviour
  def calc_state(radix_state) do
    # calc the frame for the Menubar, we can choose to discard the other frames in the stack
    %{framestack: [menubar_f | _editor_f]} =
      ScenicWidgets.Core.Utils.FlexiFrame.calc(
        radix_state.gui.viewport,
        {:standard_rule, linemark: radix_state.menu_bar.height}
      )

    %{
      layer: 2,
      frame: menubar_f,
      menu_map: Flamelex.GUI.TopMenuBar.calc_menu_map(radix_state),
      font: radix_state.menu_bar.font
    }
  end

  @impl Flamelex.GUI.Layer.Behaviour
  def render(layer_state, _radix_state) do
    {:ok,
     Scenic.Graph.build()
     |> ScenicWidgets.MenuBar.add_to_graph(
       %{
         frame: layer_state.frame,
         menu_map: layer_state.menu_map,
         font: layer_state.font
       },
       id: :menu_bar
     )}
  end

end
