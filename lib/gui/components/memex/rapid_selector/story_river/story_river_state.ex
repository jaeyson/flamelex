
defmodule Flamelex.GUI.Component.StoryRiver.State do

  # edit mode or not (this has to be on a hypercard state, inside a list...)

# story_river: %{
#   focussed_tidbit: nil,
#   open_tidbits: [],
#   scroll: {0, 0}
# }

  # eventually this will be a struct but for now...
  def new do
    %{
      focussed_tidbit: nil,
      open_tidbits: [],
      scroll: {0, 0}
    }
  end
end
