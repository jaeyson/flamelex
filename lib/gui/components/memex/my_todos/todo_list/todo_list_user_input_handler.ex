defmodule Flamelex.GUI.Component.TODOlist.UserInputHandler do
  require Logger
  use ScenicWidgets.ScenicEventsDefinitions
  alias Flamelex.GUI.Component.TODOlist

  def handle(rdx, @left_shift) do
    [{TODOlist.Reducer, {:set_turbo, true}}]
  end

  def handle(rdx, @left_shift_up) do
    [{TODOlist.Reducer, {:set_turbo, false}}]
  end

  @ignored_keys [
    @left_alt_dn,
    @left_alt_up
  ]
  def handle(rdx, input) when input in @ignored_keys do
    Logger.warn("#{__MODULE__} ignoring input: #{inspect(input)}")
    :ignore
  end
end
