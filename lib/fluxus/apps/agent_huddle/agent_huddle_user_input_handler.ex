defmodule Flamelex.GUI.Component.AgentHuddle.UserInputHandler do
  @moduledoc """
  Handles user input for the Agent huddle component.
  """

  require Logger
  use ScenicWidgets.ScenicEventsDefinitions
  alias Flamelex.GUI.Component.AgentHuddle
  alias Flamelex.GUI.Component.AgentHuddle.Reducer

  def handle(rdx, input) do
    case input do
      # Match on specific inputs and return actions
      _ ->
        Logger.warn("#{__MODULE__} received unhandled input: #{inspect(input)}")
        :ignore
    end
  end
end
