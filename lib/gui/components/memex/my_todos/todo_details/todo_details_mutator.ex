defmodule Flamelex.GUI.Component.TODOdetails.Mutator do
  @moduledoc """
  A collection of functions that mutate the radix state.
  """
  alias Flamelex.Fluxus.RadixState
  alias Flamelex.GUI.Component.TODOdetails

  def open_details(%RadixState{} = rdx, %Memelex.TidBit{} = t) do
    rdx |> put_in([:apps, :todo_details], TODOdetails.State.new(%{tidbit: t}))
  end

  def close_details(%RadixState{} = rdx) do
    rdx
    # |> Flamelex.Fluxus.TODOsMutators.open_details(t)
    |> Flamelex.Fluxus.Layer01Mutators.set_layout(:full_screen)
    # TODO this would be better to remove TODOdetails rather than "put in" a new list of just TODOlist
    |> Flamelex.Fluxus.Layer01Mutators.set_active_apps([TODOlist])
    |> put_in([:apps, :todo_details], TODOdetails.State.new())
  end

  def set_mode(%RadixState{} = rdx, :edit) do
    # new_state =
    #   rdx.apps.todo_details
    #   |> TODOdetails.State.cast(%{edit_description?: true})

    rdx |> put_in([:apps, :todo_details, :edit_description?], true)
  end

  # def open_details(%RadixState{} = rdx, %Memelex.TidBit{} = t) do
  #   rdx |> put_in([:apps, :todo_details], t)
  # end
end
