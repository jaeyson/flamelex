defmodule Flamelex.GUI.Component.TODOdetails.Reducer do
  alias Flamelex.Fluxus.RadixState
  alias Flamelex.GUI.Component.TODOdetails

  def process(%RadixState{} = rdx, {:refresh_tidbit, t}) do
    # IO.puts "$$$$$$$$$$$$$$$$$$$ refresh tidbit $$$$$$$$$$$$$$$$$$$"
    rdx
    # |> Flamelex.Fluxus.TODOsMutators.open_details(t)
    |> TODOdetails.Mutator.open_details(t)
  end

  def process(%RadixState{} = rdx, :close_todo_details) do
    rdx
    |> TODOdetails.Mutator.close_details()
  end

  @valid_modes [:view, :edit]
  def process(%RadixState{} = rdx, {:set_mode, m}) when m in @valid_modes do
    rdx
    |> TODOdetails.Mutator.set_mode(m)
  end

  # note the use of same variable name to so an exact bind in the pattern match
  def process(
        %RadixState{apps: %{todo_details: %{tidbit: %{uuid: tidbit_uuid}}}} = rdx,
        {:edit_todo, tidbit_uuid}
      ) do
    rdx
    |> TODOdetails.Mutator.set_mode(:edit)
  end
end
