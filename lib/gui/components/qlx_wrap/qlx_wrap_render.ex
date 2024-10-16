defmodule Flamelex.GUI.Component.QlxWrap.Render do
  alias Flamelex.GUI.Component.QlxWrap
  alias Quillex.GUI.Components.Buffer

  def go(%Widgex.Frame{} = frame, %QlxWrap.State{} = state) do
    # TODO this is hacky but it works for now, eventually we should do something more sophisticated
    buf_ref = hd(state.buffers)

    graph =
      Scenic.Graph.build()
      |> Scenic.Primitives.group(
        fn graph ->
          graph
          |> Buffer.add_to_graph(%{frame: frame, buf_ref: buf_ref, font: state.font})
        end,
        translate: frame.pin.point
      )
  end
end

#   #   # def handle_event({:tab_clicked, tab_label}, _from, %{assigns: %{app: app}} = scene) do
#   #   #   # Flamelex.Fluxus.action({MemexReducer, :new_tidbit})
#   #   #   # TODO buffer.find, then Buffer.activate
#   #   #   Logger.warn("TAB CLICKED")
#   #   #   buffer_api(app).activate(tab_label)
#   #   #   {:noreply, scene}
#   #   # end

#   #   # def handle_event({:hover_tab, tab_label}, _from, scene) do
#   #   #   # Flamelex.Fluxus.action({MemexReducer, :new_tidbit})
#   #   #   # TODO buffer.find, then Buffer.activate
#   #   #   Logger.warn("TAB HOVERED")
#   #   #   {:noreply, scene}
#   #   # end

#   #   def render(%{frame: editor_frame, radix_state: %{editor: %{buffers: buf_list}} = radix_state}) do
#   #     [active_buffer] = buf_list |> Enum.filter(&(&1.id == radix_state.editor.active_buf))

#   #     Scenic.Graph.build()
#   #     |> Scenic.Primitives.group(
#   #       fn graph ->
#   #         graph
#   #         # |> render_tab_selector()
#   #         |> render_text_pad(%{
#   #           frame: editor_frame,
#   #           buffer: active_buffer,
#   #           font: radix_state.editor.font
#   #         })
#   #       end,
#   #       id: :editor
#   #     )
#   #   end

#   #   #   def render_tab_selector do
#   #   #             # |> TabSelector.add_to_graph(%{
#   #   #         #   frame:
#   #   #         #     Frame.new(width: scene.assigns.frame.dimens.width, height: @tab_selector_height),
#   #   #         #   theme: theme,
#   #   #         #   tab_list: tab_list,
#   #   #         #   active: active_buffer.id,
#   #   #         #   font: font,
#   #   #         #   menu_item: %{width: 220}
#   #   #         # })
#   #   #   end

#   #   def render_text_pad(graph, %{
#   #         frame: %Frame{} = frame,
#   #         buffer: %Buffer{} = buffer,
#   #         font: %Font{} = font
#   #       }) do
#   #     graph
#   #     |> TextPad.add_to_graph(
#   #       %{
#   #         frame: calc_text_pad_frame(frame),
#   #         state:
#   #           TextPad.new(%{
#   #             buffer: buffer,
#   #             font: font
#   #           })
#   #       },
#   #       id: {:text_pad, buffer.id}
#   #     )
#   #   end

#   #   def calc_text_pad_frame(%Frame{pin: pin, size: {w, h}}) do
#   #     # NOTE: Add the extra 10 because on MacOS the stupid rounded corners of the GLFW frame make the window look stupid, F-U Steve J.
#   #     Frame.new(pin: pin, size: {w, h - 10})
#   #   end

#   #   # NOTE - we need these because Editor component is used by both QuilleEx & Flamelex...
#   #   def radix_store(%{assigns: %{app: app}}) do
#   #     Module.concat(app, Fluxus.RadixStore)
#   #   end

#   #   def radix_reducer(%{assigns: %{app: app}}) do
#   #     #  Module.concat(app, Fluxus.Reducers.RadixReducer)
#   #     QuillEx.Reducers.RadixReducer
#   #   end

#   #   defp theme do
#   #     %{
#   #       active: {58, 94, 201},
#   #       background: {72, 122, 252},
#   #       border: :light_grey,
#   #       focus: :cornflower_blue,
#   #       highlight: :sandy_brown,
#   #       text: :white,
#   #       thumb: :cornflower_blue
#   #     }
#   #   end
# end

# NOTE: Don't handle events here, just let them bubble-up to the
#      parent scene - https://hexdocs.pm/scenic/Scenic.Scene.html#module-event-filtering
# def handle_event({:tab_clicked, tab_label}, _from, scene) do
#     {:noreply, scene}
# end

# #TODO right now, this re-draws every time there's a RadixState update - we ought to compare it against what we have, & only update/broadcast if it really changed
# # This case takes us from :inactive -> 2 buffers
# def handle_info({:radix_state_change, %{buffers: buf_list, active_buf: active_buf} = new_state}, scene) when length(buf_list) >= 2 and length(buf_list) <= 7 do
#     #Logger.debug "#{__MODULE__} ignoring radix_state: #{inspect new_state}, scene_state: #{inspect scene.assigns.state}}"
#     Logger.debug "#{__MODULE__} drawing a 2-tab TabSelector --"

#     {:ok, ibm_plex_mono_fm} = TruetypeMetrics.load("./assets/fonts/IBMPlexMono-Regular.ttf")
#     fm = ibm_plex_mono_fm #TODO get this once and keep hold of it in the state

#     render_tabs = fn(init_graph) ->
#         {final_graph, _final_offset} =
#             buf_list
#             # |> Enum.map(fn %{id: id} -> id end) # we only care about id's...
#             |> Enum.with_index()
#             |> Enum.reduce({init_graph, _init_offset = 0}, fn {%{id: label}, index}, {graph, offset} ->
#                     label_width = @menu_width #TODO - either fixed width, or flex width (adapts to size of label)
#                     item_width  = label_width+@left_margin
#                     carry_graph = graph
#                     |> SingleTab.add_to_graph(%{
#                             label: label,
#                             ref: label,
#                             active?: label == active_buf,
#                             margin: 10,
#                             font: %{
#                                 size: @tab_font_size,
#                                 ascent: FontMetrics.ascent(@tab_font_size, fm),
#                                 descent: FontMetrics.descent(@tab_font_size, fm),
#                                 metrics: fm},
#                             frame: %{
#                                 pin: {offset, 0}, #REMINDER: coords are like this, {x_coord, y_coord}
#                                 size: {item_width, 40} #TODO dont hard-code
#                             }})
#                     {carry_graph, offset+item_width}
#             end)

#         final_graph

#     end

#     new_graph = scene.assigns.graph
#     |> Scenic.Graph.delete(:tab_selector)
#     |> Scenic.Primitives.group(fn graph ->
#         graph
#         |> Scenic.Primitives.rect({scene.assigns.frame.width, 40}, fill: scene.assigns.theme.background)
#         |> render_tabs.()
#       end, [
#          id: :tab_selector
#       ])

#     new_scene = scene
#     |> assign(graph: new_graph)
#     # |> assign(state: %{buffers: buf_list})
#     |> push_graph(new_graph)

#     {:noreply, new_scene}
# end

# # Single buffer open
# def handle_info(
#       {:radix_state_change,
#       %{editor: %{buffers: [%{id: id, data: text, cursor: cursor_coords}], active_buf: id}}},
#       scene
#     )
#     when is_bitstring(text) do
#   Logger.debug("drawing a single TextPad since we have only one buffer open!")

#   # TODO replace this with render
#   new_graph =
#     Scenic.Graph.build()
#     |> Scenic.Primitives.group(
#       fn graph ->
#         graph
#         |> TextPad.add_to_graph(
#           enhance_args(scene, %{
#             text: text,
#             cursor: cursor_coords,
#             frame: full_screen_buffer(scene)
#           })
#         )
#       end,
#       translate: scene.assigns.frame.pin,
#       id: :editor
#     )

#   new_scene =
#     scene
#     |> assign(graph: new_graph)
#     |> push_graph(new_graph)

#   {:noreply, new_scene}
# end
