defmodule Flamelex.GUI.Layers.Layer0 do
  use Scenic.Component
  alias Flamelex.GUI.Components.Renseijin

  def validate(%{frame: %Widgex.Frame{}} = data) do
    {:ok, data}
  end

  def init(
        %Scenic.Scene{} = scene,
        %{frame: %Widgex.Frame{} = frame},
        _opts
      ) do
    graph =
      Scenic.Graph.build()
      |> Renseijin.add_to_graph(%{
        frame: frame
      })

    new_scene =
      scene
      |> assign(frame: frame)
      |> assign(graph: graph)
      |> push_graph(graph)

    {:ok, new_scene}
  end
end


# defmodule Flamelex.GUI.Layers.LayerZero do
#   # @behaviour Flamelex.GUI.Layer.Behaviour
#   alias Flamelex.GUI.Component.{Renseijin, Renseijin}
#   alias Widgex.Structs.LayerCake

#   # @impl Flamelex.GUI.Layer.Behaviour
#   def cast(
#         %{
#           root: %{active_app: :desktop}
#         } = radix_state
#       ) do
#     # use the same frame as Editor for the Renseijin
#     %{framestack: [_menubar_f | editor_f]} =
#       ScenicWidgets.Core.Utils.FlexiFrame.calc(
#         radix_state.gui.viewport,
#         {:standard_rule, linemark: radix_state.desktop.menu_bar.height}
#       )

#     old_frame = hd(editor_f)

#     # TODO change this over eventually...
#     new_frame = Widgex.Structs.Frame.new(old_frame.pin, old_frame.size)

#     layer_state = Renseijin.State.cast(radix_state)

#     %LayerCake{
#       id: :renseijin,
#       frame: new_frame,
#       state: layer_state,
#       layout: %Widgex.Structs.GridLayout{},
#       layerable: __MODULE__
#     }
#   end

#   def cast(_radix_state) do
#     %{visible?: false}
#   end

#   # # TODO render should accept a %LayerCake{} struct
#   # @impl Flamelex.GUI.Layer.Behaviour
#   # def render({:radix_state, _rdx}, _frame, %Renseijin.State{visible?: false}) do
#   #   {:ok, Scenic.Graph.build()}
#   # end

#   #   @impl Flamelex.GUI.Layer.Behaviour
#   # def render(
#   #       {:radix_state,
#   #        %{
#   #          root: %{active_app: :desktop},
#   #          desktop: %{renseijin: %{visible?: true}}
#   #        }},
#   #       %LayerCake{}
#   #     ) do
#   #   {:ok, Scenic.Graph.build()}
#   # end

#   # def render(%RadixState{}, %LayerOne{}) do
#   #   {:ok, Scenic.Graph.build()}
#   # end

#   # takes in a radix state  a %State{} and returns a Scenic Graph
#   # def render should *only* accept a module which implements the Layer.Behaviour
#   def render(
#         # %{
#         #   root: %{active_app: :desktop},
#         #   desktop: %{renseijin: %{visible?: true}}
#         # },
#         _rdx,
#         %LayerCake{
#           frame: %Widgex.Structs.Frame{} = frame,
#           state: %Renseijin.State{visible?: true} = state
#         }
#       ) do
#     case Process.whereis(Renseijin) do
#       nil ->
#         new_graph =
#           Scenic.Graph.build()
#           |> Renseijin.add_to_graph({frame, state})

#         {:ok, new_graph}

#       pid when is_pid(pid) ->
#         GenServer.cast(pid, {:redraw, state})
#         :ignore
#     end
#   end
# end
