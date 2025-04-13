defmodule Flamelex.GUI.Layers.Layer3.State do
  use StructAccess

  defstruct [
    current_dir: nil,
    open_memex_popup_open?: false,
    show_window_mode_overlay?: false
  ]

  def new do
    %__MODULE__{
      current_dir: System.user_home()
    }
  end
end
