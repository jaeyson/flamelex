defmodule Flamelex.GUI.Component.TODOdetails.Reducer do
  def process(%Flamelex.Fluxus.RadixState{} = rdx, {:refresh_tidbit, t}) do
    rdx
    |> Flamelex.Fluxus.TODOsMutators.open_details(t)
  end
end
