defmodule Flamelex.GUI.Layers.Layer4.State do
  use StructAccess

  defstruct kommander_active?: false

  def new do
    %__MODULE__{}
  end
end
