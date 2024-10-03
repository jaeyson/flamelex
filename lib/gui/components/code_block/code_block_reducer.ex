defmodule Flamelex.GUI.Component.CodeBlock.Reducer do
  @moduledoc """
  Processes actions and updates the Radix state for the Code block component.
  """

  alias Flamelex.Fluxus.RadixState
  alias Flamelex.GUI.Component.CodeBlock
  alias Flamelex.GUI.Component.CodeBlock.Mutator

  def process(%RadixState{} = rdx, action) do
    case action do
      # Match on specific actions and call mutators
      _ ->
        rdx
    end
  end
end
