defmodule Flamelex.GUI.Component.AgentHuddle.Reducer do
  @moduledoc """
  Processes actions and updates the Radix state for the Agent huddle component.
  """
  alias Flamelex.Fluxus.RadixState
  alias Flamelex.GUI.Component.AgentHuddle

  def process(%RadixState{} = rdx, :open_chat_window) do
    # case action do
    #   # Match on specific actions and call mutators
    #   _ ->
    #     rdx
    # end
    rdx
    |> AgentHuddle.Mutator.open_chat_window()
  end

  def process(%RadixState{} = rdx, :open_agent_settings) do
    # case action do
    #   # Match on specific actions and call mutators
    #   _ ->
    #     rdx
    # end
    rdx
    |> AgentHuddle.Mutator.open_agent_settings()
  end
end
