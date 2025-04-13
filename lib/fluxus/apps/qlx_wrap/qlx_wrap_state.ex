defmodule Flamelex.GUI.Component.QlxWrap.State do
  @moduledoc """
  State management for the QlxWrap component.
  """
  use StructAccess

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

  defstruct buffers: [],
            # it's layers all the way down baby...
            # implement a layer system for the QlxWrap component
            # layers: [],
            req_save: %{
              do?: false,
              buf: nil,
              data: nil
            },
            font: nil,
            active_buf: nil,
            layout: :whole_frame,
            splits: []

            # for keeping track of whether leader was pressed etc we *obviously* should be tracking qlx wrap input in it's own place :facepalm:
            # history: %{keystrokes: []}


  def new do
    %__MODULE__{font: font()}
  end

  def font do
    font_size = 24
    font_name = :ibm_plex_mono

    {:ok, font_metrics} = TruetypeMetrics.load("./assets/fonts/IBM_Plex_Mono/IBMPlexMono-Regular.ttf")

    Quillex.Structs.BufState.Font.new(%{
      name: font_name,
      size: font_size,
      metrics: font_metrics
    })
  end
end
