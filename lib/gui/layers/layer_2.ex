defmodule Flamelex.GUI.Layers.NeoLayer02 do
  use Widgex.Layer

  # def cast_rdx_to_layer_state(%{editor: e, menubar: m, theme: t}) do
  #   %{editor: e, menubar: m, memex: %{active?: false}, theme: t}
  # end

  # def cast_rdx_to_layer_state(%{memex: %{active?: false}} = rdx) do
  def cast_rdx_to_layer_state(rdx) do
    %{
      menubar: %{height: rdx.menubar.height},
      menu_map: Flamelex.GUI.Menus.MainMenu.calc_menu_map(rdx)
      # theme: rdx.theme
    }
  end

  # def cast_rdx_to_layer_state(%{memex: %{active?: true, env: memex_env}} = rdx)
  #     when not is_nil(memex_env) do
  #   %{
  #     editor: rdx.editor,
  #     menubar: rdx.menubar,
  #     memex: %{active?: true, memex_env: memex_env},
  #     theme: rdx.theme
  #   }
  # end

  def render(%Frame{} = layer_f, layer_state) do
    # take the width of the MenuBar from the frame we're given
    graph =
      Scenic.Graph.build()
      # |> ScenicWidgets.NeoMenuBar.add_to_graph(%{
      #   frame: calc_menubar_frame(layer_f, layer_state),
      #   state: cast_menubar_state(layer_state),
      #   theme: layer_state.theme
      # })
      |> ScenicWidgets.MenuBar.add_to_graph(
        %{
          # {
          #   calc_menubar_frame(layer_f, layer_state),
          #   calc_menubar_state(layer_state)
          # }
          frame: calc_menubar_frame(layer_f, layer_state),
          menu_map: layer_state.menu_map
          #   font: menu_bar.font
        }
        # id: :menu_bar
      )

    {:ok, graph}
  end

  # def calc_menubar_state(layer_state) do
  #   menu_map = Flamelex.GUI.Menus.MainMenu.calc_menu_map(layer_state)
  #   # %{mode: :inactive, menu_map: menu_map}
  #   %ScenicWidgets.MenuBar{menu_map: menu_map}
  # end

  def calc_menubar_frame(layer_f, %{menubar: %{height: menubar_h}}) do
    layer_f
    |> Frame.v_split(px: menubar_h)
    |> List.first()
  end
end
