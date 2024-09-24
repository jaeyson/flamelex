defmodule Flamelex.GUI.Component.TODOdetails.Reducer do
  alias Flamelex.Fluxus.RadixState

  def process(%RadixState{} = rdx, {:refresh_tidbit, t}) do
    rdx
    |> Flamelex.Fluxus.TODOsMutators.open_details(t)
  end

  def process(%RadixState{} = rdx, {:edit_todo, tidbit_uuid}) do
    IO.puts("SHOULD OPEN IN EDIT MODE")
    rdx
    # |> Flamelex.Fluxus.TODOsMutators.open_details(t)
  end
end
