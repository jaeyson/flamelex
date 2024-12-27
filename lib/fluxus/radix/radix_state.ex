defmodule Flamelex.Fluxus.RadixState do
  use StructAccess
  alias Flamelex.GUI.Layers.{Layer01, Layer3, Layer4}

  alias Flamelex.GUI.Component.{
    QlxWrap,
    TODOlist,
    TODOdetails,
    RapidSelector,
    HighCouncil,
    AgentHuddle
  }

  # On the concept of breaking up Radix state
  # If I do another iteration of RadixStore, I will have this process accept actions
  # and have it contain a minimal, "top layer" state - changes to the top layer, may
  # propagate down through various other layers, but we route actions down to the state
  # process which consumes them. This process then fires off updates (potentially). So
  # if I type a new letter and the active buffer gets it, processes the input and adds
  # another character to the line - the fact that this update took place is broadcast

  # the argument for using radix struct is that I can pattern match on exactly a radix state
  # the argument against is that I might want to dynamically add keys to it...
  defstruct theme: nil,
            menubar: nil,
            # popup_modal: nil,
            memex: nil,
            fonts: nil,
            layers: nil,
            apps: nil,
            gui: nil

  def new() do
    %__MODULE__{
      layers: %{
        one: Layer01.State.new(),
        three: Layer3.State.new(),
        four: Layer4.State.new()
      },
      apps: %{
        todo_list: TODOlist.State.new(),
        todo_details: TODOdetails.State.new(),
        rapid_selector: RapidSelector.State.new(),
        qlx_wrap: QlxWrap.State.new(),
        high_council: HighCouncil.State.new(query_memex?: false),
        agent_huddle: AgentHuddle.State.new()
      },
      memex: %{
        active?: false,
        env: nil,
        open_memex_popup_open?: false
      },
      # theme: theme(),
      #   # TODO move menubar to some other place in the radix state structure (should be under layer 2 probably)
      menubar: %{
        font: :ibm_plex_mono,
        height: 60
      },
      # popup_modal: %{
      #   active?: false
      # },
      fonts: fonts()
      # gui: %{}
    }
  end

  def theme do
    Scenic.Primitive.Style.Theme.preset(:light)
    |> Scenic.Primitive.Style.Theme.normalize()
  end

  def fonts do
    # TruetypeMetrics.load("./assets/fonts/IBM_Plex_Mono/IBMPlexMono-Regular.ttf")
    {:ok, ibm_plex_mono_font_metrics} =
      TruetypeMetrics.load("./assets/fonts/IBM_Plex_Mono/IBMPlexMono-Regular.ttf")

    {:ok, noto_sans_font_metrics} =
      TruetypeMetrics.load("./assets/fonts/Noto_Sans/static/NotoSans-Regular.ttf")

    {:ok, meroitic_font_metrics} =
      TruetypeMetrics.load("./assets/fonts/Noto_Sans_Meroitic/NotoSansMeroitic-Regular.ttf")

    %{
      ibm_plex_mono: %{
        metrics: ibm_plex_mono_font_metrics
      },
      noto_sans: %{
        metrics: noto_sans_font_metrics
      },
      meroitic: %{
        metrics: meroitic_font_metrics
      }
    }
  end

  def mutate(%__MODULE__{}) do
    raise "not yet but this is what we should have instead of mutators.ex (maybe)"
  end
end

# defmodule Flamelex.Fluxus.RadixMutators do
#   @moduledoc """
#   A collection of functions that mutate the radix state.
#   """
# end


# defmodule Flamelex.Fluxus.Structs.RadixState do
#   @moduledoc """
#   In latin, `fluxus` means "flow" and `radix` means "root". FluxusRadix
#   is the root node in the state-tree of fluxus internally (now renamed
#   to RadixState).

#   The FluxusRadix holds the highest-level flamelex state, for example:

#      - the active buffer
#      - the system mode
#      - the input history (both keystrokes, & actions)
#      - it acts as a conduit for all user-input

#   We need a single junction-point where all the data required to make
#   decisions can be combined & acted upon - this is it.

#   What belongs in the domain of RadixState? Anything which affects both
#   buffers & GUI components. e.g. opening the Command buffer requires:

#   * changing the input mode
#   * checking the contents of `Flamelex.Buffer.Command`
#   * rendering the GUI.Component
#   * etc...

#   changing the input mode alone requires that we make our changes at the
#   FluxusRadix level, so we might as well just put the rest as side-effects
#   in the reducer at this level. This makes sense because it's a heirarchy -
#   since we need to change the input it's an FluxusRadix level change, so
#   the function to open the Command buffer must be implemented at this level.
#   <!-- If we don't need to alter anything at this level, then do not implement -->
#   it in a reducer/handler at this level, handle it somewhere lower.

#   When we need to trigger something at the Radix level, we can use actions.
#   Actions get handled by the TansStatum module, though the actual processing
#   occurs in a seperate process, running under the
#   `Flamelex.Fluxus.HandleAction.TaskSupervisor`.

#   User input also gets funneled through this process - the RadixState (which
#   includes the user-input history) and the input itself are handled by
#   one of the InputHandler functions, which operate in basically the same
#   manner as reducers - spun up into their own process & handled in there.
#   Inputs usually lead to an action being dispatched, which is sent back
#   to FluxusRadix (kind of a loop-back) to be then handled.
#   """

#   # TODO this should implement the `ScenicWidgets.Fluxus.RadixState` behaviour

#   use Flamelex.Lib.ProjectAliases

#   @max_keystroke_history_limit 50
#   @max_action_history_limit 50
#   require Logger

#   @doc """
#   This function calculates & returns the default RadixState -
#   the one that is populated upon applications startup.
#   """
#   def initialize(%{memex: %{active?: true}}) do
#     # REMINDER: if memex is not active, this call will print nasty errors in the console...
#     memex_env = Memelex.environment_details()

#     base_radix_state()
#     |> Map.merge(%{memex: %{active?: true, env: memex_env}})
#     |> calc_menu_map()
#   end

#   def initialize(%{memex: %{active?: false}}) do
#     base_radix_state()
#     |> Map.merge(%{memex: %{active?: false}})
#     |> calc_menu_map()
#   end

#   def base_radix_state do
#     # TODO initialize the whole all with some default layer states

#     {:ok, ibm_plex_mono_font_metrics} =
#       TruetypeMetrics.load("./assets/fonts/IBM_Plex_Mono/IBMPlexMono-Regular.ttf")

#     %{
#       root: %{
#         active_app: :desktop,
#         # graph: nil,
#         layers: %{
#           one: %{
#             layout: %{
#               editor: :full_screen
#             }
#           }
#         }
#         # layers: [ # The final %Graph{} which we are holding on to for, for each layer
#         #    #NOTE: We use a Keyword list, as it works better for pattern matching than maps with keys
#         #    one: nil,
#         #    two: nil,
#         #    three: nil,
#         #    four: nil
#         # ]
#       },
#       gui: %{
#         viewport: nil,
#         theme: Flamelex.GUI.Utils.Theme.default()
#         # fonts: %{
#         #    primary: ScenicWidgets.TextPad.Structs.Font.new(%{
#         #       name: :ibm_plex_mono,
#         #       metrics: ibm_plex_mono_font_metrics
#         #    })
#         # }
#       },
#       desktop: %{
#         renseijin: %Flamelex.GUI.Component.Renseijin.State{
#           visible?: true,
#           animate?: false
#         },
#         menu_bar: %{
#           font: :ibm_plex_mono,
#           # menu_map: Flamelex.GUI.TopMenuBar.calc_menu_map(radix_state)
#           height: 60,
#           show?: true,
#           font_size: 36,
#           sub_menu: %{
#             height: 40,
#             font_size: 22
#           }
#         }
#       },
#       projects: %{
#         open_proj: nil,
#         proj_list: []
#       },
#       editor: %{
#         font:
#           ScenicWidgets.TextPad.Structs.Font.new(%{
#             name: :ibm_plex_mono,
#             metrics: ibm_plex_mono_font_metrics,
#             size: 24
#           }),
#         graph: nil,
#         # A list of %Buffer{} structs
#         buffers: [],
#         active_buf: nil,
#         config: %{
#           keymap: Flamelex.KeyMappings.Vim,
#           scroll: %{
#             # invert: %{ # change the direction of scroll wheel
#             #   horizontal?: true,
#             #   vertical?: false
#             # },
#             # higher value means faster scrolling
#             speed: %{
#               horizontal: 5,
#               vertical: 3
#             }
#           }
#         }
#       },
#       kommander: %{
#         hidden?: true,
#         buffer:
#           Quillex.Structs.BufState.new(%{
#             id: {:buffer, Flamelex.API.Kommander},
#             type: :text,
#             data: "",
#             mode: :edit
#           }),
#         font:
#           ScenicWidgets.TextPad.Structs.Font.new(%{
#             name: :ibm_plex_mono,
#             metrics: ibm_plex_mono_font_metrics,
#             size: 24
#           })
#       },
#       # widget_workbench: %{
#       #    graph: nil,
#       # },
#       history: %{
#         keystrokes: []
#         # actions:      []
#       },
#       memex: nil
#     }
#   end

#   def calc_menu_map(rdx) do
#     # TODO maybe instead of calculating & storing this in the radix state, it should be in the state of the MenuBar component,
#     # or even in that components state... but then again this is the central state repo, it should probably get updated here too..
#     menu_map = Flamelex.GUI.TopMenuBar.calc_menu_map(rdx)
#     put_in(rdx, [:desktop, :menu_bar, :menu_map], menu_map)
#   end

#   # defdelegate change_font(radix_state, new_font),
#   #    to: QuillEx.Fluxus.Structs.RadixState

#   # defdelegate change_font_size(radix_state, direction),
#   #    to: QuillEx.Fluxus.Structs.RadixState

#   # defdelegate change_editor_scroll_state(radix_state, new_scroll_state),
#   #    to: QuillEx.Fluxus.Structs.RadixState

#   # TODO it should be possible to use the action/keystroke history to record macros

#   # @modes [:normal, :insert, {:kommand_buffer_active, :insert}]

#   # #TODO ok, figure out how modes is gonna work, with active buffer etc...
#   # def set(%__MODULE__{} = radix_state, [mode: m]) when m in @modes do
#   #   %{radix_state|mode: m}
#   # end

#   # def record(%__MODULE__{keystroke_history: keystroke_history} = radix_state, keystroke: %{input: k}) do
#   #   new_keystroke_history =
#   #       keystroke_history
#   #       |> add_to_list(k, max_length: @max_keystroke_history_limit)

#   #   %{radix_state|keystroke_history: new_keystroke_history}
#   # end

#   # def record(%__MODULE__{action_history: action_history} = radix_state, action: a) do
#   #   updated_history =
#   #     action_history
#   #     |> add_to_list(a, max_length: @max_action_history_limit)

#   #   %{radix_state|action_history: updated_history}
#   # end

#   # def set_active_buffer(%__MODULE__{} = radix_state, b) do
#   #   %{radix_state|active_buffer: b}
#   # end

#   # def record(%__MODULE__{action_history: action_history} = radix_state, action: a) do
#   #   new_action_history =
#   #       action_history
#   #       |> add_to_list(a, max_length: @max_action_history_limit)

#   #   %{radix_state|action_history: new_action_history}
#   # end

#   # # def last_keystroke_was?(%__MODULE__{keystroke_history: [last|_rest]}, x)
#   # #   when last == x do true end
#   # # def last_keystroke_was?(%__MODULE__{keystroke_history: _hist}, _x), do: false

#   # def add_to_list(list, x, max_length: max_list_length)
#   # when length(list) >= max_list_length
#   # do
#   #   list_minus_one_item = # https://stackoverflow.com/questions/52319984/remove-last-element-from-list-in-elixir
#   #     list
#   #     |> Enum.reverse()
#   #     |> tl()
#   #     |> Enum.reverse()

#   #   list_minus_one_item ++ [x]
#   # end

#   # def add_to_list(list, x, max_length: _max_list_length)
#   # when length(list) >= 0
#   # do
#   #   list ++ [x]
#   # end

#   # def last_keystroke(%__MODULE__{keystroke_history: []}), do: nil
#   # def last_keystroke(%__MODULE__{keystroke_history: hist}) when length(hist) > 0 do
#   #   hist
#   #   |> Enum.reverse()
#   #   |> hd()
#   # end

#   def mutate(radix_state, :open_widget_workbench) do
#     radix_state
#     |> put_in([:root, :active_apps], :widget_workbench)
#   end
# end
