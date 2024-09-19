defmodule Flamelex.Fluxus.TODOsMutators do
  @moduledoc """
  A collection of functions that mutate the radix state.
  """
  alias Flamelex.Fluxus.RadixState

  # def set_state(rdx, state) do
  #   put_in(rdx, [:todos], state)
  # end

  def refresh_todo_list(%RadixState{} = rdx) do
    todo_list = Memelex.My.TODOs.all()
    rdx |> put_in([:apps, :todo_list, :list], todo_list)
  end

  def refresh_todo_list(%RadixState{} = rdx, filter: f) do
    todo_list = Memelex.My.TODOs.all(filter: f)
    rdx |> put_in([:apps, :todo_list, :list], todo_list)
  end

  def open_details(%RadixState{} = rdx, %Memelex.TidBit{} = t) do
    rdx |> put_in([:apps, :todo_details], t)
  end
end
