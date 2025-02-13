
defmodule Flamelex.GUI.Component.CollectionsMantel.State do
  use StructAccess
  alias Memelex.GUI.Components.CollectionsMantel

  defstruct collections: []
  # edit mode or not (this has to be on a hypercard state, inside a list...)

# story_river: %{
#   focussed_tidbit: nil,
#   open_tidbits: [],
#   scroll: {0, 0}
# }

  # eventually this will be a struct but for now...
  def new(_args) do
    %__MODULE__{}
  end
end
