defmodule Flamelex.GUI.Layers.Layer3.State do
  use StructAccess

  defstruct [
    open_memex_popup_open?: false
  ]

  def new do
    %__MODULE__{}
  end
end
