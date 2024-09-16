defmodule Flamelex.Fluxus.Layer01Mutators do
  @moduledoc """
  A collection of functions that mutate the radix state.
  """
  alias Memelex.GUI.Components.RapidSelector

  @valid_layouts [:split_screen, :full_screen]
  def set_layout(rdx_state, layout) when layout in @valid_layouts do
    rdx_state
    |> put_in([:layers, :one, :layout], layout)
  end

  def set_active_app(
        %{layers: %{one: %{active_apps: []}}} = rdx_state,
        {_component_module, _args} = app
      ) do
    rdx_state
    |> put_in([:layers, :one, :active_apps], [
      app
    ])
  end

  def open_tidbit(
        %{layers: %{one: %{active_apps: [{RapidSelector, state}]}}} = rdx_state,
        tidbit
      ) do
    rdx_state
    |> update_app_state(RapidSelector, fn state ->
      state
      |> put_in([:story_river, :open_tidbits], [tidbit | state.story_river.open_tidbits])
    end)
  end

  def update_app_state(rdx_state, app_name, fun) do
    update_in(
      rdx_state[:layers][:one][:active_apps],
      fn active_apps ->
        Enum.map(active_apps, fn
          {^app_name, state} ->
            {app_name, fun.(state)}

          other_app ->
            other_app
        end)
      end
    )
  end
end
