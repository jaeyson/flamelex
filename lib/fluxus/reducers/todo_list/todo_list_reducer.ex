defmodule Flamelex.GUI.Component.TODOlist.Reducer do
  alias Flamelex.GUI.Component.TODOlist

  def process(rdx, :show_todos) do
    rdx
    |> Flamelex.Fluxus.Layer01Mutators.set_layout(:full_screen)
    |> Flamelex.Fluxus.Layer01Mutators.set_active_apps([TODOlist])
    |> Flamelex.Fluxus.TODOsMutators.refresh_todo_list()
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
