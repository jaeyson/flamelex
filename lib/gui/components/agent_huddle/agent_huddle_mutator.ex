defmodule Flamelex.GUI.Component.AgentHuddle.Mutator do
  @moduledoc """
  Functions to mutate the Radix state for the Agent huddle component.
  """

  alias Flamelex.Fluxus.RadixState

  def set_agent(%RadixState{} = rdx, %{uuid: tidbit_uuid}) do
    # Perform state mutation
    # raise "not implemented"
    IO.puts("HERE WE WOULD PUT THE AGENT IN")
    rdx
  end
end
