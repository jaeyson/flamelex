defmodule Flamelex.GUI.Component.RapidSelector.Renderizer do
  alias Flamelex.GUI.Component.RapidSelector

  def render(frame, %RapidSelector.State{} = state) do
    [left, mid_l, _mid, _mid_r, right] = Widgex.Frame.col_split(frame, 5)

    middle_three =
      Widgex.Frame.new(%{
        pin: mid_l.pin,
        size: {3 * mid_l.size.width, mid_l.size.height}
      })

    Scenic.Graph.build()
    |> Memelex.GUI.Components.CollectionsMantel.add_to_graph(%{
      frame: left,
      state: state.collections_mantel
    })
    |> Memelex.GUI.Components.StoryRiver.add_to_graph(%{
      frame: middle_three
      # state: state.story_river
    })
    |> Memelex.GUI.Component.RapidSelector.Lens.add_to_graph(%{
      frame: right,
      state: state
    })

    # |> Scenic.Primitives.text("Memelex",
    #    font: :ibm_plex_mono,
    #    # font: args.font.name,
    #    # font_size: args.font.size,
    #    # fill: args.theme.text,
    #    fill: :white,
    #    # TODO this is what scenic does https://github.com/boydm/scenic/blob/master/lib/scenic/component/input/text_field.ex#L198
    #    translate: {100, 100}
    # )
  end
end
