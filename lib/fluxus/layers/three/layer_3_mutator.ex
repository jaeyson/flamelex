defmodule Flamelex.GUI.Layers.Layer3.Mutator do
  @moduledoc """
  A collection of functions that mutate the radix state.
  """
  alias Flamelex.Fluxus.RadixState

  def activate_popup(%RadixState{} = rdx) do
    rdx
    |> put_in([:layers, :three, :open_memex_popup_open?], true)
  end

  def deactivate_popup(%RadixState{} = rdx) do
    rdx
    |> put_in([:layers, :three, :open_memex_popup_open?], false)
  end

  def set_overlay(rdx, :window_manager) do
    rdx
    |> put_in([:layers, :three, :show_window_mode_overlay?], false)
  end
end
