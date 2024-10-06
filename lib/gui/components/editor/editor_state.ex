defmodule Flamelex.GUI.Component.Editor.State do
  @moduledoc """
  State management for the Editor component.
  """

  use StructAccess

  defstruct active_buf: nil,
            buffers: []

  def new do
    %__MODULE__{}
  end
end
