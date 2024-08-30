# defmodule Flamelex.GUI.Layers.Layer03 do
#   alias ScenicWidgets.Core.Structs.Frame

#   @behaviour Flamelex.GUI.Layer.Behaviour

#   alias Widgex.Structs.LayerCake

#   # TODO
#   @kommander_height 50

#   @impl Flamelex.GUI.Layer.Behaviour
#   def cast(%{gui: %{viewport: %{size: {vp_width, vp_height}}}}) do
#     kommander_frame =
#       ScenicWidgets.Core.Structs.Frame.new(
#         pin: {0, vp_height - @kommander_height},
#         # TODO why do we need this +1? Without it we see a think black stripe on the right-hand side
#         size: {vp_width + 1, @kommander_height}
#       )

#     # %{
#     #   layer: 3,
#     #   frame: kommander_frame
#     # }

#     %LayerCake{
#       id: :kommander,
#       frame: kommander_frame,
#       state: %{},
#       layout: %Widgex.Structs.GridLayout{},
#       layerable: __MODULE__
#     }
#   end

#   # @impl Flamelex.GUI.Layer.Behaviour
#   # def render(
#   #       _rx,
#   #       # %{
#   #       #   root: %{active_app: :desktop},
#   #       #   desktop: %{renseijin: %{visible?: true}}
#   #       # }},
#   #       # %LayerCake{}
#   #       a1,
#   #       a2
#   #     ) do
#   #   dbg()
#   #   {:ok, Scenic.Graph.build()}
#   # end

#   # @impl Flamelex.GUI.Layer.Behaviour
#   # def render({:radix_state, radix_state}, %{frame: kommander_frame}) do
#   #   # def render(a, bi) do
#   #   # def render(vp, radix_state) do
#   #   # dbg()
#   #   # {:ok, Scenic.Graph.build()}
#   #   {:ok,
#   #    Scenic.Graph.build()
#   #    |> Flamelex.GUI.Component.Kommander.add_to_graph(%{
#   #      frame: kommander_frame,
#   #      radix_state: radix_state
#   #    })}
#   # end

#   # @impl Flamelex.GUI.Layer.Behaviour
#   # def render({:radix_state, radix_state}, %{frame: kommander_frame}) do
#   #   {:ok,
#   #    Scenic.Graph.build()
#   #    |> Flamelex.GUI.Component.Kommander.add_to_graph(%{
#   #      frame: kommander_frame,
#   #      radix_state: radix_state
#   #    })}
#   # end

#   # def render(
#   #       %Scenic.ViewPort{} = viewport,
#   #       %{}
#   #     ) do
#   #   # TODO use WIdgex for this - define the layout
#   #   %{framestack: [menubar_f | _editor_f]} =
#   #     ScenicWidgets.Core.Utils.FlexiFrame.calc(
#   #       viewport,
#   #       # TODO call this top-ine rule, or find
#   #       {:standard_rule, linemark: menu_bar.height}
#   #     )

#   #   graph =
#   #     Scenic.Graph.build()
#   #     |> ScenicWidgets.MenuBar.add_to_graph(
#   #       %{
#   #         frame: menubar_f,
#   #         menu_map: menu_bar.menu_map,
#   #         font: menu_bar.font
#   #       },
#   #       id: :menu_bar
#   #     )

#   #   {:ok, graph}
#   # end

#   def render(
#         %Scenic.ViewPort{size: {vp_width, vp_height}} = viewport,
#         radix_state
#       ) do
#     kommander_frame =
#       ScenicWidgets.Core.Structs.Frame.new(
#         pin: {0, vp_height - @kommander_height},
#         # TODO why do we need this +1? Without it we see a think black stripe on the right-hand side
#         size: {vp_width + 1, @kommander_height}
#       )

#     {:ok,
#      Scenic.Graph.build()
#      |> Flamelex.GUI.Component.Kommander.add_to_graph(%{
#        frame: kommander_frame,
#        radix_state: radix_state
#      })}
#   end

#   # def cast(%{gui: %{viewport: %{size: {vp_width, vp_height}}}}) do
#   #   # %{
#   #   #   layer: 3,
#   #   #   frame: kommander_frame
#   #   # }

#   #   %LayerCake{
#   #     id: :kommander,
#   #     frame: kommander_frame,
#   #     state: %{},
#   #     layout: %Widgex.Structs.GridLayout{},
#   #     layerable: __MODULE__
#   #   }
#   # end
# end
