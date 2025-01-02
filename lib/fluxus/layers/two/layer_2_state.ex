defmodule Flamelex.GUI.Layers.Layer2.State do
  use StructAccess

  defstruct menubar: nil,
            menu_map: nil

  def new(%Flamelex.Fluxus.RadixState{} = rdx) do
    %__MODULE__{
      menubar: %{
        font: :ibm_plex_mono,
        height: 60
      },
      menu_map: Flamelex.GUI.Menus.MainMenu.calc_menu_map(rdx)
    }
  end

end
