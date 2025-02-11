defmodule Flamelex.GUI.Component.RapidSelector.Mutator do

  def open_tidbit(
    %{layers: %{one: %{active_apps: [RapidSelector]}}} = rdx_state,
    tidbit
  ) do
    update_in(rdx_state[:apps][:rapid_selector],
      fn state ->
        put_in(state, [:story_river, :open_tidbits], [tidbit | state.story_river.open_tidbits])
      end
    )
  end

end
