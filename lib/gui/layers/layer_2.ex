defmodule Flamelex.GUI.Layers.Layer02 do
  @moduledoc """
  Layer 2 is the MenuBar/Desktop component
  """

  # @behaviour Flamelex.GUI.Layer.Behaviour
  alias Widgex.Structs.LayerCake

  defstruct menu_bar: nil

  defmodule MenuBar do
    defstruct([:height, :menu_map, :font])

    def cast(%{desktop: %{menu_bar: menu_bar}}) do
      %__MODULE__{
        height: menu_bar.height,
        menu_map: menu_bar.menu_map,
        font: menu_bar.font
      }
    end
  end

  # we use this to store the central state of the layer, so that
  # we can check if we need to re-render or not
  def cast(radix_state) do
    menu_bar = MenuBar.cast(radix_state)

    %__MODULE__{
      menu_bar: menu_bar
    }
  end

  def render(
        %Scenic.ViewPort{} = viewport,
        %__MODULE__{menu_bar: menu_bar}
      ) do
    # TODO use WIdgex for this - define the layout
    %{framestack: [menubar_f | _editor_f]} =
      ScenicWidgets.Core.Utils.FlexiFrame.calc(
        viewport,
        # TODO call this top-ine rule, or find
        {:standard_rule, linemark: menu_bar.height}
      )

    graph =
      Scenic.Graph.build()
      |> ScenicWidgets.MenuBar.add_to_graph(
        %{
          frame: menubar_f,
          menu_map: menu_bar.menu_map,
          font: menu_bar.font
        },
        id: :menu_bar
      )

    {:ok, graph}
  end

  # def render(init_state, radix_state) do
  #   IO.puts("lopl woops")
  #   require IEx
  #   IEx.pry()
  #   # render(radix_state)
  #   {:ok, Scenic.Graph.build()}
  # end

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

# @impl Flamelex.GUI.Layer.Behaviour
# def cast(radix_state) do
#   # calc the frame for the Menubar, we can choose to discard the other frames in the stack
#   %{framestack: [menubar_f | _editor_f]} =
#     ScenicWidgets.Core.Utils.FlexiFrame.calc(
#       radix_state.gui.viewport,
#       {:standard_rule, linemark: radix_state.desktop.menu_bar.height}
#     )

#   %{
#     layer: 2,
#     frame: menubar_f,
#     menu_map: radix_state.desktop.menu_bar.menu_map,
#     font: radix_state.desktop.menu_bar.font
#   }
# end

# @impl Flamelex.GUI.Layer.Behaviour
# def render(
#       {:radix_state,
#        %{
#          root: %{active_app: :desktop},
#          desktop: %{renseijin: %{visible?: true}}
#        }},
#       %LayerCake{}
#     ) do
#   {:ok, Scenic.Graph.build()}
# end
