defmodule Flamelex.GUI.Component.TODOdetails.Mutator do
  @moduledoc """
  A collection of functions that mutate the radix state.
  """
  alias Flamelex.Fluxus.RadixState
  alias Flamelex.GUI.Component.{TODOlist, TODOdetails}

  def open_details(%RadixState{} = rdx, %Memelex.TidBit{} = t) do
    rdx |> put_in([:apps, :todo_details], TODOdetails.State.new(%{tidbit: t}))
  end

  def close_details(%RadixState{} = rdx) do
    rdx
    # |> Flamelex.Fluxus.TODOsMutators.open_details(t)
    |> Flamelex.GUI.Layers.Layer01.Mutator.set_layout(:full_screen)
    # TODO this would be better to remove TODOdetails rather than "put in" a new list of just TODOlist
    |> Flamelex.GUI.Layers.Layer01.Mutator.set_active_apps([TODOlist])
    |> put_in([:apps, :todo_details], TODOdetails.State.new())
  end

  # TODO clean this up, edit_description?!?!?? **&?
  def set_mode(%RadixState{} = rdx, :view) do
    rdx
    |> put_in([:apps, :todo_details, :edit_description?], false)
  end

  def set_mode(%RadixState{} = rdx, :edit) do
    rdx
    |> put_in([:apps, :todo_details, :edit_description?], true)
  end

  # def open_details(%RadixState{} = rdx, %Memelex.TidBit{} = t) do
  #   rdx |> put_in([:apps, :todo_details], t)
  # end
end
