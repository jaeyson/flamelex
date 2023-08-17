defmodule Flamelex.GUI.Layers.LayerTwo do
  # NOTE: Something in here has to be about layouts
  # NOTE: Layer 2 is the MenuBar/Desktop component

  @behaviour Flamelex.GUI.Layer.Behaviour
  alias Widgex.Structs.LayerCake

  @impl Flamelex.GUI.Layer.Behaviour
  def cast(radix_state) do
    # calc the frame for the Menubar, we can choose to discard the other frames in the stack
    %{framestack: [menubar_f | _editor_f]} =
      ScenicWidgets.Core.Utils.FlexiFrame.calc(
        radix_state.gui.viewport,
        {:standard_rule, linemark: radix_state.desktop.menu_bar.height}
      )

    %{
      layer: 2,
      frame: menubar_f,
      menu_map: radix_state.desktop.menu_bar.menu_map,
      font: radix_state.desktop.menu_bar.font
    }
  end

  @impl Flamelex.GUI.Layer.Behaviour
  def render(
        {:radix_state,
         %{
           root: %{active_app: :desktop},
           desktop: %{renseijin: %{visible?: true}}
         }},
        %LayerCake{}
      ) do
    {:ok, Scenic.Graph.build()}
  end

  # @impl Flamelex.GUI.Layer.Behaviour
  # def render({:radix_state, _rdx}, layer_state) do
  #   {:ok,
  #    Scenic.Graph.build()
  #    |> ScenicWidgets.MenuBar.add_to_graph(
  #      %{
  #        frame: layer_state.frame,
  #        menu_map: layer_state.menu_map,
  #        font: layer_state.font
  #      },
  #      id: :menu_bar
  #    )}
  # end
end
