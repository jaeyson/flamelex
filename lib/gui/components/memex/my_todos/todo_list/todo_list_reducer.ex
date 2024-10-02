defmodule Flamelex.GUI.Component.TODOlist.Reducer do
  alias Flamelex.GUI.Component.TODOlist
  alias Flamelex.GUI.Component.TODOdetails

  def process(rdx, :show_todos) do
    rdx
    |> Flamelex.GUI.Layers.Layer01.Mutator.set_layout(:full_screen)
    |> Flamelex.GUI.Layers.Layer01.Mutator.set_active_apps([TODOlist])
    |> TODOlist.Mutator.refresh_todo_list()
  end

  def process(rdx, {:set_turbo, turbo?}) when is_boolean(turbo?) do
    rdx
    |> TODOlist.Mutator.set_turbo(turbo?)
  end

  def process(rdx, {:open_todo, %Memelex.TidBit{} = t}) do
    rdx
    |> Flamelex.GUI.Layers.Layer01.Mutator.set_layout(:split_screen)
    |> Flamelex.GUI.Layers.Layer01.Mutator.set_active_apps([TODOlist, TODOdetails])
    |> TODOdetails.Mutator.open_details(t)
  end

  @valid_filters [:all, :this_week]
  def process(rdx, {:filter_todos, filter_by}) when filter_by in @valid_filters do
    filter = rdx.apps.todo_list.filter
    IO.inspect("new todo list reducer filter is #{filter_by}")

    rdx
    # TODO here, we should update something about the TODOlist state, so that the dropdown renders the correct filter
    |> TODOlist.Mutator.set_filter(filter: filter_by)
    # |> IO.inspect(label: "Reducer.process/2 did we even do it?")
    |> TODOlist.Mutator.refresh_todo_list(filter: filter_by)
  end
end

# defmodule Flamelex.Fluxus.TODOlistReducer do
#   def process(
#         rdx_state,
#         {app, {:set_scroll, scroll}}
#       ) do
#     rdx_state
#     |> Flamelex.GUI.Layers.Layer01.Mutator.set_scroll(app, scroll)
#   end
# end
