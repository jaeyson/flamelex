defmodule Flamelex.GUI.Component.CodeBlock.UserInputHandler do
  @moduledoc """
  Handles user input for the Code block component.
  """

  require Logger
  use ScenicWidgets.ScenicEventsDefinitions
  alias Flamelex.GUI.Component.CodeBlock
  alias Flamelex.GUI.Component.CodeBlock.Reducer

  def handle(rdx, input) do
    case input do
      # Match on specific inputs and return actions
      _ ->
        Logger.warn("#{__MODULE__} received unhandled input: #{inspect(input)}")
        :ignore
    end
  end
end
