defmodule Flamelex.GUI.Component.StoryRiver.Mutator do
  alias Flamelex.GUI.Component.RapidSelector

    # |> RapidSelector.Mutator.open_tidbit(
    #   Map.merge(draft_tidbit, %{
    #     gui: %{
    #       mode: :normal,
    #       focus: :title,
    #       cursors: %{
    #         # TODO we need to ensure no titles contain newoine chars, or if we do, then we need to allow ourselves to handle it - probably we should be able to just say "put the cursor in final position" & let TextPad figure it out...
    #         # we need the +1 because a string of length zero is still position 1 in our editor
    #         title: %{line: 1, col: String.length(t.title) + 1},
    #         body: %{line: 1, col: 1}
    #       }
    #     }
    #   })
    # )

  #TODO here, rdx state isnt matching for some reason
  #TODO yeh  no shit
  def new_draft_tidbit(
    %{layers: %{one: %{active_apps: [RapidSelector]}}} = rdx_state
  ) do
    # update_in(
    #   rdx_state[:apps][:rapid_selector],
    #   fn state ->
    #     put_in(state, [:story_river, :open_tidbits], [tidbit | state.story_river.open_tidbits])
    #   end
    # )

    # draft_t = %{t: Memelex.My.Wiki.new(), gui: %{mode: :edit}}



    # draft_t = Memelex.My.Wiki.new()
    # current_list = rdx_state.apps.rapid_selector.story_river.open_tidbits

    raise "thank you Jeremy"
    rdx_state
    # |> put_in([:apps, :rapid_selector, :story_river, :open_tidbits], [draft_t | current_list])
  end

  def new_draft_collection(%{layers: %{one: %{active_apps: [RapidSelector]}}} = rdx_state) do
    current_list = rdx_state.apps.rapid_selector.story_river.open_tidbits
    draft_collection_t = Memelex.My.Collections.new_draft()

    rdx_state
    |> put_in(
      [:apps, :rapid_selector, :story_river, :open_tidbits],
      [draft_collection_t | current_list]
    )
  end

  def open_tidbit(
        %{layers: %{one: %{active_apps: [RapidSelector]}}} = rdx_state,
        tidbit
      ) do
    update_in(
      rdx_state[:apps][:rapid_selector],
      fn state ->
        put_in(state, [:story_river, :open_tidbits], [tidbit | state.story_river.open_tidbits])
      end
    )
  end

  def close_tidbit(
        %{layers: %{one: %{active_apps: [RapidSelector]}}} = rdx_state,
        %{tidbit_uuid: tidbit_uuid}
      ) do
    update_in(
      rdx_state[:apps][:rapid_selector],
      fn state ->
        state
        |> update_in([:story_river, :open_tidbits], fn open_tidbits ->
          Enum.reject(open_tidbits, &(&1.uuid == tidbit_uuid))
        end)
      end
    )
  end

end
