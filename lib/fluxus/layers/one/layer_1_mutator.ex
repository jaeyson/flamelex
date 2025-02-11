defmodule Flamelex.GUI.Layers.Layer01.Mutator do
  @moduledoc """
  A collection of functions that mutate the radix state.
  """
  alias Flamelex.GUI.Component.RapidSelector

  @valid_layouts [:split_screen, :full_screen]
  def set_layout(rdx_state, layout) when layout in @valid_layouts do
    rdx_state
    |> put_in([:layers, :one, :layout], layout)
  end

  def set_active_apps(rdx_state, active_apps) when is_list(active_apps) do
    rdx_state
    |> put_in([:layers, :one, :active_apps], active_apps)
  end

  # def open_tidbit(
  #       %{layers: %{one: %{active_apps: [RapidSelector]}}} = rdx_state,
  #       tidbit
  #     ) do
  #   update_in(
  #     rdx_state[:apps][:rapid_selector],
  #     fn state ->
  #       put_in(state, [:story_river, :open_tidbits], [tidbit | state.story_river.open_tidbits])
  #     end
  #   )
  # end


  def open_project(
        %Flamelex.Fluxus.RadixState{} = rdx,
        project_dir
      ) do
    rdx
    # |> put_in([:layers, :one, :active_apps], [])
    |> put_in([:layers, :one, :projects], [project_dir])

    # update_in(
    #   rdx_state[:apps][:rapid_selector],
    #   fn state ->
    #     put_in(state, [:story_river, :open_tidbits], [project_dir | state.story_river.open_tidbits])
    #   end
    # )
  end

  # def set_turbo(rdx_state, turbo?) when is_boolean(turbo?) do
  #   update_in(
  #     rdx_state[:layers][:one],
  #     fn layer_one ->
  #       %{layer_one | turbo?: turbo?}
  #     end
  #   )
  # end

  # def set_scroll(rdx_state, app_name, {_x, _y} = scroll) do
  #   update_app_state(rdx_state, app_name, fn state ->
  #     state
  #     |> put_in([:scroll], scroll)
  #   end)
  # end
end
