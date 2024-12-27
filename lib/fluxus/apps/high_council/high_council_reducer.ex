defmodule Flamelex.GUI.Component.HighCouncil.Reducer do
  @moduledoc """
  Processes actions and updates the Radix state for the High council component.
  """

  alias Flamelex.Fluxus.RadixState
  alias Flamelex.GUI.Component.HighCouncil
  alias Flamelex.GUI.Component.HighCouncil.Mutator
  alias Flamelex.GUI.Component.AgentHuddle
  alias Flamelex.GUI.Layers.Layer01.Mutator, as: Layer1

  def process(
        %RadixState{} = rdx,
        :show_agents
      ) do
    agents = Memelex.My.Agents.all()

    rdx
    |> Layer1.set_active_apps([HighCouncil])
    |> Layer1.set_layout(:full_screen)
    |> Mutator.set_agents(agents)
  end

  def process(
        %RadixState{layers: %{one: %{active_apps: [HighCouncil]}}} = rdx,
        :new_agent
      ) do
    agents = Memelex.My.Agents.all()

    rdx
    |> Mutator.set_new_agent_mode(true)
    # |> Mutator.set_agents(agents)
  end

  def process(
        %RadixState{layers: %{one: %{active_apps: [HighCouncil]}}} = rdx,
        :refresh_agents
      ) do
    agents = Memelex.My.Agents.all()

    rdx
    # |> Mutator.set_new_agent_mode(true)
    |> Mutator.set_agents(agents)
  end

  def process(
        %RadixState{layers: %{one: %{active_apps: [HighCouncil]}}} = rdx,
        {:select_agent, tidbit_uuid}
      ) do
    rdx
    |> Layer1.set_active_apps([AgentHuddle])
    |> Layer1.set_layout(:full_screen)
    |> AgentHuddle.Mutator.set_agent(%{uuid: tidbit_uuid})
  end

  def process(
        %RadixState{} = rdx,
        :cancel_new_agent_creation
      ) do
    rdx
    |> Mutator.set_new_agent_mode(false)
  end

  # def process(state, action) do
  #   Logger.error("Unable to process action. #{inspect(action)}")
  #   IO.inspect(state)
  #   :ignore
  # end
end
