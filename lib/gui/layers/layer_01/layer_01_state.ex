defmodule Flamelex.GUI.Layers.Layer01.State do
  use StructAccess

  defstruct layout: :full_screen,
            active_apps: [],
            projects: nil

  def new do
    %__MODULE__{}
  end
end
