defmodule Flamelex.GUI.Component.HighCouncil.Mutator do
  @moduledoc """
  Functions to mutate the Radix state for the High council component.
  """
  alias Flamelex.Fluxus.RadixState

  def set_agents(%RadixState{} = rdx, agents) do
    put_in(rdx, [:apps, :high_council, :agents], agents)
  end

  def new_agent(%RadixState{} = rdx) do
    put_in(rdx, [:apps, :high_council, :new_agent_mode?], true)
  end
end
