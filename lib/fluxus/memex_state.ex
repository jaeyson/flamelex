# defmodule Flamelex.Fluxus.Structs.MemexState do
#   #  alias ScenicWidgets.TextPad.Structs.Font
#   require Logger

#   def init(%{memex: %{env: memex_env}} = _radix_state) do
#     # {:ok, {_type, ibm_plex_mono_font_metrics}} = Scenic.Assets.Static.meta(:ibm_plex_mono)

#     memex_name =
#       case memex_env do
#         nil ->
#           Logger.warning("No name in the Memex state...")
#           nil

#         %{name: memex_name} when is_binary(memex_name) ->
#           memex_name
#       end

#     %{
#       name: memex_name,
#       gui: %{
#         viewport: nil
#       },
#       story_river: %{
#         focussed_tidbit: nil,
#         open_tidbits: [],
#         # TODO put the scroll in another process, then it a) will hopefully be more seperated and b) we can just update that one (maybe even just by calling update_opts) and don't have to re-render every component we're scrolling, which is kinda crazy
#         scroll: {0, 0}
#       },
#       sidebar:
#         %{
#           # active_tab: :ctrl_panel,
#           # search: %{
#           #   active?: false,
#           #   string: ""
#           # }
#         },
#       history: %{
#         keystrokes: []
#         # actions:      []
#       }
#     }
#   end
# end
