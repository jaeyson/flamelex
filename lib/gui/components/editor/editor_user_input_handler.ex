defmodule Flamelex.GUI.Component.Editor.UserInputHandler do
  @moduledoc """
  Handles user input for the Editor component.
  """

  require Logger
  use ScenicWidgets.ScenicEventsDefinitions
  alias Flamelex.GUI.Component.Editor
  alias Flamelex.GUI.Component.Editor.Reducer

  def handle(rdx, input) do
    case input do
      # Match on specific inputs and return actions
      _ ->
        Logger.warn("#{__MODULE__} received unhandled input: #{inspect(input)}")
        :ignore
    end
  end
end
