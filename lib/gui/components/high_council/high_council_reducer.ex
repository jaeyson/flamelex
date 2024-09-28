defmodule Flamelex.GUI.Component.HighCouncil.Reducer do
  @moduledoc """
  Processes actions and updates the Radix state for the High council component.
  """

  alias Flamelex.Fluxus.RadixState
  alias Flamelex.GUI.Component.HighCouncil
  alias Flamelex.GUI.Component.HighCouncil.Mutator
  alias Flamelex.GUI.Layers.Layer01.Mutator, as: Layer1

  # def process(%RadixState{} = rdx, action) do
  #   case action do
  #     # Match on specific actions and call mutators
  #     _ ->
  #       rdx
  #   end
  # end

  def process(%RadixState{} = rdx, :show_agents) do
    agents = Memelex.My.Agents.all()

    rdx
    |> Layer1.set_active_apps([HighCouncil])
    |> Layer1.set_layout(:full_screen)
    |> Mutator.set_agents(agents)
  end
end
