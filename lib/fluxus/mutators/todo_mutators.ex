defmodule Flamelex.Fluxus.TODOsMutators do
  @moduledoc """
  A collection of functions that mutate the radix state.
  """

  # def set_state(rdx, state) do
  #   put_in(rdx, [:todos], state)
  # end

  def refresh_todo_list(rdx) do
    todo_list = Memelex.My.TODOs.all()
    rdx |> put_in([:apps, :todo_list, :list], todo_list)
  end
end
