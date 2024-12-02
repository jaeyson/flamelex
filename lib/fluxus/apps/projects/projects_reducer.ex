defmodule Flamelex.Fluxus.Reducers.Projects do
  #   @moduledoc false
  #   use Flamelex.Lib.ProjectAliases
  #   require Logger

  #   def process(radix_state, :close_all) do
  #     new_radix_state =
  #       radix_state
  #       |> put_in([:projects, :open_proj], nil)
  #       |> put_in([:projects, :proj_list], [])

  #     {:ok, new_radix_state}
  #   end

  alias Flamelex.GUI.Layers.Layer01

  def process(
        radix_state,
        {:open_project_directory, project_dir}
      ) do
    radix_state
    # |> Layer01.Mutator.show_file_tree?(true)
    |> Layer01.Mutator.open_project(project_dir)

    # TODO this is not correct lol
    # TODO update proj_list
    # |> put_in([:projects, :flamelex], project_dir)
  end
end
