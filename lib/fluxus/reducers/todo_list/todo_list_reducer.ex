defmodule Flamelex.GUI.Component.TODOlist.Reducer do
  alias Flamelex.GUI.Component.TODOlist
  alias Flamelex.GUI.Component.TODOdetails

  def process(rdx, :show_todos) do
    rdx
    |> Flamelex.Fluxus.Layer01Mutators.set_layout(:full_screen)
    |> Flamelex.Fluxus.Layer01Mutators.set_active_apps([TODOlist])
    |> Flamelex.Fluxus.TODOsMutators.refresh_todo_list()
  end

  def process(rdx, {:set_turbo, turbo?}) when is_boolean(turbo?) do
    rdx |> TODOlist.State.set_turbo(turbo?)
  end

  def process(rdx, {:open_todo, %Memelex.TidBit{} = t}) do
    rdx
    |> Flamelex.Fluxus.Layer01Mutators.set_layout(:split_screen)
    |> Flamelex.Fluxus.Layer01Mutators.set_active_apps([TODOlist, TODOdetails])
    |> Flamelex.Fluxus.TODOsMutators.open_details(t)
  end

  def process(rdx, {:filter_todos, filter_by}) do
    rdx
    |> Flamelex.Fluxus.TODOsMutators.refresh_todo_list(filter: filter_by)
  end

  # def process(rdx, {:set_turbo, turbo?}) when is_boolean(turbo?) do
  #   rdx
  #   # |> Flamelex.Fluxus.Layer01Mutators.set_turbo(turbo)
  # end
end

# defmodule Flamelex.Fluxus.TODOlistReducer do
#   def process(
#         rdx_state,
#         {app, {:set_scroll, scroll}}
#       ) do
#     rdx_state
#     |> Flamelex.Fluxus.Layer01Mutators.set_scroll(app, scroll)
#   end
# end
