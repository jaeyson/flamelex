defmodule Flamelex.GUI.Component.QlxWrap.State do
  @moduledoc """
  State management for the QlxWrap component.
  """
  use StructAccess

  defstruct buffers: []

  def new do
    %__MODULE__{}
  end
end
