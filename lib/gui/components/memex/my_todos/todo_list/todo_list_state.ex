defmodule Flamelex.GUI.Component.TODOlist.State do
  use StructAccess
  alias Flamelex.Fluxus.RadixState

  defstruct list: [],
            selected: nil,
            scroll: {0, 0},
            turbo_scroll?: false

  def new do
    %__MODULE__{}
  end
end
