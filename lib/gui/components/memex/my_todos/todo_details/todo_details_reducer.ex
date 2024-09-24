defmodule Flamelex.GUI.Component.TODOdetails.Reducer do
  alias Flamelex.Fluxus.RadixState
  alias Flamelex.GUI.Component.TODOdetails

  def process(%RadixState{} = rdx, {:refresh_tidbit, t}) do
    rdx
    # |> Flamelex.Fluxus.TODOsMutators.open_details(t)
    |> TODOdetails.Mutator.open_details(:edit)
  end

  # note the use of same variable name to so an exact bind in the pattern match
  def process(
        %RadixState{apps: %{todo_details: %{tidbit: %{uuid: tidbit_uuid}}}} = rdx,
        {:edit_todo, tidbit_uuid}
      ) do
    rdx
    |> TODOdetails.Mutator.set_mode(:edit)
  end

  def process(
        # %RadixState{apps: %{todo_details: %{tidbit: %{uuid: tidbit_uuid}}}} = rdx,
        rdx,
        {:edit_todo, tidbit_uuid}
      ) do
    # rdx |> Mutator.set_mode(:edit)
    IO.puts("WTF IS THIS GUY GOING ON ABOUT")
    IO.inspect(rdx.apps.todo_details)
    rdx
  end
end
