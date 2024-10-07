defmodule Flamelex.GUI.Component.QlxWrap do
  @moduledoc """
  This is the QuillEx wrapper, it sits "between" Flamelex
  & quillex. We need one foot in both worlds, because when we render
  from within flamelex, we cant delegate things like "set layer1 to fullscreen"
  to quillex, because quillex doesnt know what layer1 is, that's a flamelex concept

  That said, as much as possible we want to have quillex be the owner of GUI components,
  because that library is supposed to be a shareable, embeddable GUI library
  """
  use Scenic.Component
  alias __MODULE__

  def validate(%{frame: %Widgex.Frame{}} = data) do
    {:ok, data}
  end

  def init(scene, %{frame: %Widgex.Frame{} = frame}, _opts) do
    # TODO this would be a cool place to do something better here...
    state = Flamelex.Fluxus.RadixStore.get().apps.qlx_wrap
    buf_ref = state.buffers |> List.first()

    graph =
      Scenic.Graph.build()
      |> Quillex.GUI.Components.Buffer.add_to_graph(%{frame: frame, buf_ref: buf_ref})

    init_scene =
      scene
      |> assign(frame: frame)
      |> assign(graph: graph)
      |> assign(state: state)
      |> push_graph(graph)

    # NOTE - this component needs (does it?) to subscribe to both radix state changes and buffer changes
    Flamelex.Lib.Utils.PubSub.subscribe(topic: :radix_state_change)
    Quillex.Utils.PubSub.subscribe(topic: {:buffers, buf_ref.uuid})

    {:ok, init_scene}
  end
end
