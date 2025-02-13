defmodule Memelex.GUI.Components.HyperCard.Renderizer do



  # def render(
  #   %Scenic.Graph{} = graph,
  #   %Scenic.Scene{assigns: %{state: %{frame: %Widgex.Frame{} = old_frame}}} = scene,
  #   %Widgex.Frame{} = new_frame,
  #   # %Layer3.State{} = state
  #   state
  # ) when old_frame != new_frame do
  #   # delete the old primitive to force a re-render from scratch
  #   graph
  #   # |> Scenic.Graph.delete(@layer_3)
  #   # |> draw_layer_3(new_frame, state)
  # end

  def render(
    %Scenic.Graph{} = graph,
    %Scenic.Scene{} = scene,
    %Widgex.Frame{} = frame,
    %Memelex.TidBit{data: %Memelex.Lib.Structs.MemexConcepts.V01.Collection{}} = t = state) do
      base_graph(graph, group_id(t))
      |> render_background(scene, frame, state, %{bg: :medium_orchid})
  end

  def render(
    %Scenic.Graph{} = graph,
    %Scenic.Scene{} = scene,
    %Widgex.Frame{} = frame,
    {:draft, %Memelex.TidBit{data: %Memelex.Lib.Structs.MemexConcepts.V01.Collection{}} = t} = state) do


    # base_graph =
    #   case Scenic.Graph.get(graph, group_id(t)) do
    #     [] ->
    #       graph
    #       # define a new group, since our `get` didn't find this group_id
    #       |> Scenic.Primitives.group(
    #         fn graph ->
    #           graph
    #         end,
    #         id: group_id(t)
    #         # translate: frame.pin.point
    #       )

    #     _primitive ->
    #       # group already exists, no need to define it
    #       graph
    #   end

    [f1, f2, f3, f4, f5, f6] = calc_frames(frame)

    base_graph(graph, group_id(t))
    |> render_background(scene, frame, state, %{bg: :green})
    |> render_draft_of_notice(scene, f1, state, %{bg: :purple})
    |> render_draft_toolbar(scene, f2, t)
    |> render_draft_title(scene, f3, t)
    # |> render_draft_tidbit_tags()
    |> render_draft_data(scene, f5, t)
    # |> render_draft_tidbit_meta()


    # |> render_text_lines(scene, frame, state, buf)
    # |> render_cursor(scene, frame, state, buf)
    # |> draw_scrollbars(args)
    # |> render_status_bar(frame, buf)
    # |> render_active_row_decoration(frame, buf, font, colors)


    #   case Scenic.Graph.get(graph, {:hypercard, t.uuid}) do
    #   [] ->
    #     graph
    #     |> Scenic.Primitives.group(fn graph ->
    #       graph
    #       |> render_background(scene, frame, state, buf)
    #       # |> render_text_lines(scene, frame, state, buf)
    #       # |> render_cursor(scene, frame, state, buf)
    #       # |> draw_scrollbars(args)
    #       # |> render_status_bar(frame, buf)
    #       # |> render_active_row_decoration(frame, buf, font, colors)
    #     end,
    #     id: {:buffer_pane, buf.uuid})

    #   _primitive ->
    #     graph
    #     |> render_background(scene, frame, state, buf)
    #     |> render_text_lines(scene, frame, state, buf)
    #     |> render_cursor(scene, frame, state, buf)
    # end
  end

  def group_id(%Memelex.TidBit{uuid: t_uuid}) do
    {:hypercard, t_uuid}
  end

  # this function finds the base group (which is the fundamental outer unit of the hypercard) OR creates it if necessary
  def base_graph(graph, group_id) do
    case Scenic.Graph.get(graph, group_id) do
      [] ->
        graph
        # define a new group, since our `get` didn't find this group_id
        |> Scenic.Primitives.group(
          fn graph ->
            graph
          end,
          id: group_id
        )

      _primitive ->
        # group already exists, no need to define it
        graph
    end
  end

  def calc_frames(%Widgex.Frame{} = frame) do
    # Define a grid with 6 rows (to produce 6 frames)
    grid =
      Widgex.Frame.Grid.new(frame)
      |> Widgex.Frame.Grid.rows([
        0.05, # row 0
        0.10, # row 1
        0.15, # row 2
        0.15, # row 3
        0.45, # row 4
        0.10  # row 5
      ])
      |> Widgex.Frame.Grid.columns([1.0])
      |> Widgex.Frame.Grid.define_areas(%{
        f1: {0, 0, 1, 1},
        f2: {1, 0, 1, 1},
        f3: {2, 0, 1, 1},
        f4: {3, 0, 1, 1},
        f5: {4, 0, 1, 1},
        f6: {5, 0, 1, 1}
      })

    # Calculate the frames for the entire grid
    grid_frames = Widgex.Frame.Grid.calculate(grid)

    # Extract each of the 6 frames by area
    f1 = Widgex.Frame.Grid.area_frame(grid, grid_frames, :f1)
    f2 = Widgex.Frame.Grid.area_frame(grid, grid_frames, :f2)
    f3 = Widgex.Frame.Grid.area_frame(grid, grid_frames, :f3)
    f4 = Widgex.Frame.Grid.area_frame(grid, grid_frames, :f4)
    f5 = Widgex.Frame.Grid.area_frame(grid, grid_frames, :f5)
    f6 = Widgex.Frame.Grid.area_frame(grid, grid_frames, :f6)

    # Return the six frames in a list
    [f1, f2, f3, f4, f5, f6]
  end
  # defp hypercard()

  defp render_draft_title(graph, _scene, frame, tidbit) do
    case Scenic.Graph.get(graph, :title) do
      [] ->
        graph
        |> Scenic.Primitives.rect(frame.size.box,
            id: :title,
            fill: :beige,
            translate: frame.pin.point
        )
        |> Scenic.Components.text_field("new Collection - #{tidbit.data.name}", id: :title, translate: {frame.pin.x+10,frame.pin.y+10})

      _primitive ->
        graph
        # |> Scenic.Graph.modify(:background,
        #   &Scenic.Primitives.update_opts(&1, fill: bg_color)
        # )
    end
  end

  # defp render_draft_data(graph, _scene, frame, %Memelex.TidBit{data: %Memelex.Lib.Structs.MemexConcepts.V01.Collection{type: nil}} = state) do
  #   case Scenic.Graph.get(graph, :data) do
  #     [] ->
  #       graph
  #       |> Scenic.Primitives.rect(frame.size.box,
  #           id: :data,
  #           fill: :light_blue,
  #           translate: frame.pin.point
  #       )
  #       |> Scenic.Primitives.text(
  #           "since this Collection has no type it will default to a list... allow user to change that here in the draft",
  #           id: :draft_of_notice_txt,
  #           fill: :white,
  #           font_size: 20,
  #           # Offset slightly inside the box
  #           translate: {
  #             (frame.pin.point |> elem(0)) + 10,
  #             (frame.pin.point |> elem(1)) + 20
  #           }
  #         )

  #       # |> Scenic.Components.text_field("new Collection", id: :title, translate: {frame.pin.x+10,frame.pin.y+10})

  #     _primitive ->
  #       graph
  #       # |> Scenic.Graph.modify(:background,
  #       #   &Scenic.Primitives.update_opts(&1, fill: bg_color)
  #       # )
  #   end
  # end

  #   def render_toolbar(graph, frame, %{gui: %{mode: :edit}} = tidbit) do
#     graph
#     |> Scenic.Primitives.group(
#       fn graph ->
#         graph
#         |> Scenic.Primitives.rect({@toolbar_width, @title_height}, fill: :purple)
#         |> Memelex.GUI.Components.IconButton.add_to_graph(
#           %{
#             frame: Widgex.Frame.new(pin: {@toolbar_width - 150, 0}, size: {50, 50}),
#             icon: "ionicons/black_32/trash.png"
#           },
#           id: {:delete, tidbit.uuid}
#         )
#         |> Memelex.GUI.Components.IconButton.add_to_graph(
#           %{
#             frame: Widgex.Frame.new(pin: {@toolbar_width - 100, 0}, size: {50, 50}),
#             icon: "ionicons/black_32/backspace.png"
#           },
#           id: {:discard_changes, tidbit.uuid}
#         )
#         |> Memelex.GUI.Components.IconButton.add_to_graph(
#           %{
#             frame: Widgex.Frame.new(pin: {@toolbar_width - 50, 0}, size: {50, 50}),
#             icon: "ionicons/black_32/save.png"
#           },
#           id: {:save, tidbit.uuid}
#         )
#       end,
#       translate: {frame.size.width - 2 * @margin - @toolbar_width, 0}
#     )
#   end

  defp render_draft_toolbar(graph, _scene, frame, tidbit) do
    case Scenic.Graph.get(graph, :toolbar) do
      [] ->
        graph
        |> Scenic.Primitives.group(fn graph ->
          graph
          |> Scenic.Primitives.rect(frame.size.box,
              id: :toolbar_bg,
              fill: :dark_grey,
              translate: frame.pin.point
          )


          |> Memelex.GUI.Components.IconButton.add_to_graph(
          %{
            frame: Widgex.Frame.new(pin: {frame.size.width - 50, 0}, size: {50, 50}),
            icon: "ionicons/black_32/save.png"
          },
          id: :save_tidbit,
          translate: frame.pin.point
        )


        end
        # translate: {frame.size.width - 2 * @margin - @toolbar_width, 0}
      )


        # |> Scenic.Components.text_field("new Collection", id: :title, translate: {frame.pin.x+10,frame.pin.y+10})

      _primitive ->
        graph
        # |> Scenic.Graph.modify(:background,
        #   &Scenic.Primitives.update_opts(&1, fill: bg_color)
        # )
    end
  end

  defp render_draft_data(graph, _scene, frame, %Memelex.TidBit{data: %Memelex.Lib.Structs.MemexConcepts.V01.Collection{type: nil}} = state) do
    case Scenic.Graph.get(graph, :data) do
      [] ->
        graph
        |> Scenic.Primitives.rect(frame.size.box,
            id: :data,
            fill: :light_blue,
            translate: frame.pin.point
        )
        |> Scenic.Primitives.text(
            "since this Collection has no type it will default to a list... allow user to change that here in the draft",
            id: :draft_of_notice_txt,
            fill: :white,
            font_size: 20,
            # Offset slightly inside the box
            translate: {
              (frame.pin.point |> elem(0)) + 10,
              (frame.pin.point |> elem(1)) + 20
            }
          )

        # |> Scenic.Components.text_field("new Collection", id: :title, translate: {frame.pin.x+10,frame.pin.y+10})

      _primitive ->
        graph
        # |> Scenic.Graph.modify(:background,
        #   &Scenic.Primitives.update_opts(&1, fill: bg_color)
        # )
    end
  end





  defp render_background(graph, _scene, frame, _state, %{bg: bg_color}) do
    case Scenic.Graph.get(graph, :background) do
      [] ->
        graph
        |> Scenic.Primitives.rect(frame.size.box,
            id: :background,
            fill: bg_color,
            translate: frame.pin.point
        )

      _primitive ->
        graph
        |> Scenic.Graph.modify(:background,
          &Scenic.Primitives.update_opts(&1, fill: bg_color)
        )
    end
  end

  defp render_draft_of_notice(graph, _scene, f1, _state, %{bg: bg_color}) do
    # If :draft_of_notification is in the state, we draw a rectangle in f1
    # if Map.has_key?(state, :draft_of_notification) do
      case Scenic.Graph.get(graph, :draft_of_notice_bg) do
        [] ->
          graph
          |> Scenic.Primitives.rect(
            f1.size.box,
            id: :draft_of_notice_bg,
            fill: bg_color,
            translate: f1.pin.point
          )
          |> Scenic.Primitives.text(
            "draft Collection",
            id: :draft_of_notice_txt,
            fill: :white,
            font_size: 20,
            # Offset slightly inside the box
            translate: {
              (f1.pin.point |> elem(0)) + 10,
              (f1.pin.point |> elem(1)) + 20
            }
          )

        _primitive ->
          graph
          |> Scenic.Graph.modify(:draft_of_notice_bg, fn primitive ->
            Scenic.Primitives.update_opts(primitive, fill: bg_color)
          end)
      end
    # else
    #   # No :draft_of_notification => do nothing (or remove the rectangle if desired)
    #   graph
    # end
  end


  # def render(graph, scene, frame, ) do
  #   # IO.inspect(state)

  #   # Widgex.Frame.Grid.new(frame)
  #   #   # Single row taking 100% of the height
  #   #   |> Grid.rows([1.0])
  #   #   # Two columns, each 50% of the width
  #   #   |> Grid.columns([0.5, 0.5])
  #   #   # |> Grid.define_areas(%{
  #   #   #   left_half: {0, 0, 1, 1},
  #   #   #   right_half: {0, 1, 1, 1}
  #   #   # })

  #   # graph
  #   # |> Scenic.Primitives.rect(frame.size.box, fill: :green, translate: frame.pin.point)
  #   # |> Scenic.Primitives.text("draft Collection:", t: {frame.pin.x + 60, frame.pin.y + 60})

  #   # Define the grid structure for title and status
  #   grid =
  #     Widgex.Frame.Grid.new(frame)
  #     # 20% for title, 30% spacing, 50% for data
  #     |> Widgex.Frame.Grid.rows([0.2, 0.3, 0.5])
  #     # Single column layout
  #     |> Widgex.Frame.Grid.columns([1.0])
  #     |> Widgex.Frame.Grid.define_areas(%{
  #       # Title section
  #       title: {0, 0, 1, 1},
  #       # Data section
  #       data: {2, 0, 1, 1}
  #     })

  #   # Calculate the frames
  #   grid_frames = Widgex.Frame.Grid.calculate(grid)
  #   title_frame = Widgex.Frame.Grid.area_frame(grid, grid_frames, :title)
  #   data_frame  = Widgex.Frame.Grid.area_frame(grid, grid_frames, :data)

  #   # Render the card with click interaction
  #   graph
  #   |> Scenic.Primitives.group(fn graph ->
  #     # Background rectangle, now clickable with :input
  #     graph
  #     # |> Scenic.Primitives.rectangle(f.size.box,
  #     #   fill: (if agent.status == :active, do: :blue, else: :orange),
  #     #   t: f.pin.point,
  #     #   id: {:agent_card, tidbit.uuid},
  #     #   input: :cursor_button
  #     # )

  #     # Title section (agent's name)
  #     |> ScenicWidgets.Markup.Header1.draw(%{
  #       frame: title_frame,
  #       text: "Draft collection title",
  #       color: :white
  #     })

  #     # # Status section (agent's state)
  #     # |> Scenic.Primitives.text("Status: #{inspect(agent_state)}",
  #     #   font_size: 14,
  #     #   translate: {f.pin.x + 10, f.pin.y + 10}
  #     # )
  #   end)
  # end

  def render(graph, scene, frame, state) do
    IO.inspect(state)
    IO.puts "rendering a Tidbit case we didnt recognise!"

    graph
    |> Scenic.Primitives.rect(frame.size.box, fill: :red, translate: frame.pin.point)
  end

end


# defmodule Memelex.GUI.Components.HyperCard.Utils do
#     require Logger



#     def human_formatted_date(date) do
# 		Logger.debug "parsing date: #{inspect date} into human readable format..."
# 		{:ok, date, 0} = DateTime.from_iso8601(date)
# 		#IO.inspect date
# 		day = case Date.day_of_week(date) do
# 				1 -> "Mon"
# 				2 -> "Tue"
# 				3 -> "Wed"
# 				4 -> "Thu"
# 				5 -> "Fri"
# 				6 -> "Sat"
# 				7 -> "Sun"
# 			end
# 		month = case date.month do
# 				1 -> "Jan"
# 				2 -> "Feb"
# 				3 -> "Mar"
# 				4 -> "Apr"
# 				5 -> "May"
# 				6 -> "Jun"
# 				7 -> "Jul"
# 				8 -> "Aug"
# 				9 -> "Sep"
# 				10 -> "Oct"
# 				11 -> "Nov"
# 				12 -> "Dec"
# 			end
# 		"#{day} #{date.day} #{month} #{date.year}"
# 	end

# end
