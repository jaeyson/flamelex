defmodule Flamelex.GUI.Component.AgentHuddle.Reducer do
  @moduledoc """
  Processes actions and updates the Radix state for the Agent huddle component.
  """

  alias Flamelex.Fluxus.RadixState
  alias Flamelex.GUI.Component.AgentHuddle
  alias Flamelex.GUI.Component.AgentHuddle.Mutator

  def process(%RadixState{} = rdx, action) do
    case action do
      # Match on specific actions and call mutators
      _ ->
        rdx
    end
  end
end
