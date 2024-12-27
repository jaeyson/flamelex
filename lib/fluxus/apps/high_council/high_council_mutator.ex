defmodule Flamelex.GUI.Component.HighCouncil.Mutator do
  @moduledoc """
  Functions to mutate the Radix state for the High council component.
  """
  alias Flamelex.Fluxus.RadixState

  def set_agents(%RadixState{} = rdx, agents) do
    put_in(rdx, [:apps, :high_council, :agents], agents)
  end

  def set_new_agent_mode(%RadixState{} = rdx, new_agent_mode?) when is_boolean(new_agent_mode?) do
    put_in(rdx, [:apps, :high_council, :new_agent_mode?], new_agent_mode?)
  end
end
