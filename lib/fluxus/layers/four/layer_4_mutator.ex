defmodule Flamelex.GUI.Layers.Layer4.Mutator do
  @moduledoc """
  A collection of functions that mutate the radix state.
  """
  alias Flamelex.Fluxus.RadixState

  def open_kommander(%RadixState{} = rdx) do
    rdx
    |> put_in([:layers, :four, :kommander_active?], true)
  end

  def close_kommander(%RadixState{} = rdx) do
    rdx
    |> put_in([:layers, :four, :kommander_active?], false)
  end

end
