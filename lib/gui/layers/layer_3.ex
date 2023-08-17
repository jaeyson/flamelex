defmodule Flamelex.GUI.Layers.LayerThree do
  alias ScenicWidgets.Core.Structs.Frame

  @behaviour Flamelex.GUI.Layer.Behaviour

  alias Widgex.Structs.LayerCake

  # TODO
  @kommander_height 50

  @impl Flamelex.GUI.Layer.Behaviour
  def cast(%{gui: %{viewport: %{size: {vp_width, vp_height}}}}) do
    kommander_frame =
      ScenicWidgets.Core.Structs.Frame.new(
        pin: {0, vp_height - @kommander_height},
        # TODO why do we need this +1? Without it we see a think black stripe on the right-hand side
        size: {vp_width + 1, @kommander_height}
      )

    %{
      layer: 3,
      frame: kommander_frame
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

  #   @impl Flamelex.GUI.Layer.Behaviour
  #   def render({:radix_state, radix_state}, %{frame: kommander_frame}) do
  #     {:ok,
  #      Scenic.Graph.build()
  #      |> Flamelex.GUI.Component.Kommander.add_to_graph(%{
  #        frame: kommander_frame,
  #        radix_state: radix_state
  #      })}
  #   end
end
