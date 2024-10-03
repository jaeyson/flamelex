defmodule Flamelex.GUI.Component.AgentHuddle.State do
  @moduledoc """
  State management for the Agent huddle component.
  """

  use StructAccess

  defstruct [
    # Define state fields here
    tidbit: nil
  ]

  def new do
    %__MODULE__{}
  end
end
