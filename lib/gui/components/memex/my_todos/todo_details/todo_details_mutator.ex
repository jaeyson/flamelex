defmodule Flamelex.GUI.Component.TODOdetails.Mutator do
  @moduledoc """
  A collection of functions that mutate the radix state.
  """
  alias Flamelex.Fluxus.RadixState

  def open_details(%RadixState{} = rdx, %Memelex.TidBit{} = t) do
    rdx |> put_in([:apps, :todo_details], t)
  end
end
