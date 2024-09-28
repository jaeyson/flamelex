defmodule Flamelex.Fluxus.RapidSelectorUserInputHandler do
  require Logger
  use ScenicWidgets.ScenicEventsDefinitions
  alias Flamelex.GUI.Layers.Layer01.Mutator

  def process(rdx_state, @left_shift) do
    IO.puts("GOT LEFT SHIFTTT")

    rdx_state
    |> Layer01Mutators.set_turbo(true)
  end

  def process(rdx, input) do
    # Logger.warn("#{__MODULE__} ignoring input: #{inspect(input)}")
    :ignore
  end
end
