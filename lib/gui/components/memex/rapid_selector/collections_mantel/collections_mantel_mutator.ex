defmodule Flamelex.GUI.Component.CollectionsMantel.Mutator do
  alias Flamelex.GUI.Component.RapidSelector
  alias Memelex.Lib.Structs.MemexConcepts.V01.Collection

  def refresh_tidbit(
    %{layers: %{one: %{active_apps: [RapidSelector]}}} = rdx_state,
    %Memelex.TidBit{uuid: t_uuid, data: %Collection{}} = t
  ) do
    update_in(
      rdx_state[:apps][:rapid_selector][:collections_mantel][:collections],
      fn collections ->
        # if it exists, overwrite it, otherwise add it to our list of collections
        if Enum.any?(collections, & &1.uuid == t_uuid) do
          Enum.map(collections, fn
            %{uuid: ^t_uuid} ->
              t

            other_t ->
              other_t
          end)
        else
          collections ++ [t]
        end
      end
    )
  end

  def refresh_tidbit(
    _rdx_state,
    _tidbit
  ) do
    :ignore
  end

  def populate_collections(rdx) do
    collections =
      Memelex.My.Wiki.all()
      |> Enum.filter(& &1.type == ["struct", Memelex.Lib.Structs.MemexConcepts.V01.Collection])

    update_in(
      rdx[:apps][:rapid_selector][:collections_mantel][:collections],
      fn _current_collections ->
        collections
      end
    )
  end

end
