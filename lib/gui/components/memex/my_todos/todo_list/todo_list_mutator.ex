defmodule Flamelex.GUI.Component.TODOlist.Mutator do
  @moduledoc """
  A collection of functions that mutate the radix state.
  """
  alias Flamelex.Fluxus.RadixState

  def refresh_todo_list(%RadixState{} = rdx) do
    todo_list = Memelex.My.TODOs.all()
    rdx |> put_in([:apps, :todo_list, :list], todo_list)
  end

  def refresh_todo_list(%RadixState{} = rdx, filter: f) do
    todo_list = Memelex.My.TODOs.all(filter: f)
    rdx |> put_in([:apps, :todo_list, :list], todo_list)
  end

  def set_turbo(%RadixState{} = rdx, turbo?) when is_boolean(turbo?) do
    put_in(rdx, [:apps, :todo_list, :turbo_scroll?], turbo?)
  end
end
