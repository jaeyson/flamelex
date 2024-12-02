defmodule Flamelex.GUI.Layers.Layer3.State do
  use StructAccess

  defstruct [
    current_dir: nil,
    open_memex_popup_open?: false
  ]

  def new do
    %__MODULE__{
      current_dir: System.user_home()
    }
  end
end
