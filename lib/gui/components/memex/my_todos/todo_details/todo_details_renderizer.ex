defmodule Flamelex.GUI.Component.TODOdetails.Renderizer do
  alias Flamelex.GUI.Component.TODOdetails

  @todo_details :todo_details

  @background_color {:color_rgb, {255, 255, 153}} # Light yellow


  # Life Admin Automations: repeated tasks

#   Creating a comprehensive todo list app requires striking a balance between simplicity and functionality. Here’s a list of key features that can make your app both user-friendly and versatile:
# Core Features

#     Task Management:
#         Create, edit, and delete tasks.
#         Set due dates and times.
#         Add task descriptions or notes.

#     Organization:
#         Categories, tags, or folders for grouping tasks.
#         Priority levels (e.g., High, Medium, Low).
#         Subtasks for breaking down larger tasks.

#     Notifications and Reminders:
#         Timely reminders for tasks.
#         Recurring tasks with customizable schedules.

#     Search and Filters:
#         Search bar to quickly find tasks.
#         Filters based on categories, priorities, or due dates.

#     Progress Tracking:
#         Mark tasks as completed.
#         Visual indicators for progress (e.g., percentage bars, streaks).

#     Custom Views:
#         Daily, weekly, and monthly views.
#         Kanban board or calendar integration.

# Advanced Features

#     Collaboration:
#         Share lists or tasks with others.
#         Assign tasks to specific users.

#     Integration:
#         Sync with calendars (Google, Outlook, etc.).
#         Integration with tools like Slack, Trello, or Notion.

#     Offline Access:
#         Full functionality offline with data syncing when online.

#     Cross-Platform Support:
#         Availability on web, mobile (iOS/Android), and desktop.

#     Smart Features:
#         Natural language input (e.g., "Meet John on Friday at 3 PM").
#         AI-based suggestions for task prioritization.

#     Data Backup and Export:
#         Cloud sync for data security.
#         Export tasks in formats like CSV, PDF, or JSON.

#     Customization:
#         Dark mode and theme options.
#         Customizable task fields or layouts.

# Gamification and Motivation

#     Streaks and Rewards:
#         Gamify task completion with streaks, points, or badges.

#     Daily Goals:
#         Set and track daily goals to maintain focus.

# Security

#     Data Privacy:
#         End-to-end encryption for user data.
#         Authentication options (e.g., password, biometrics).

# Monetization Options (if applicable)

#     Freemium Model:
#         Basic features free, with premium features like advanced analytics or team collaboration available as paid upgrades.

#     Ad-Free Experience:
#         Offer a paid tier for users to remove ads.



  def render(
    %Scenic.Graph{} = graph,
    %Widgex.Frame{} = frame,
    %TODOdetails.State{tidbit: %Memelex.TidBit{} = t} = state
  ) do


    # Wormhole.capture(fn ->
      # todo_widgets =
      #   args.state.list
      #   |> Enum.map(fn t ->
      #     {NeoHyperCard, %{tidbit: t}}
      #   end)



      # graph
      # |> Scenic.Primitives.rect(frame.size.box, fill: :red, translate: frame.pin.point)
      # title_h = 60
      # title_h = 0.1 * f.size.height
      # panel_h = 420

      # draw_raw_tidbit = fn graph, %{frame: f} = args ->
      #   graph
      #   |> Scenic.Primitives.text("#{prettify_map(t)}",
      #     font: :ibm_plex_mono,
      #     font_size: 24,
      #     fill: :white,
      #     translate: {f.pin.x + 20, f.pin.y + 20}
      #   )
      # end

      # # tidbit_actions = ["Action 1", "Action 2", "Action 3", "Action 4", "Action 5"]
      # tidbit_actions =
      #   case t.meta do
      #     [%{"actions" => actions}] ->
      #       Enum.map(actions, fn
      #         a when is_binary(a) ->
      #           a

      #         %{title: t} ->
      #           t
      #       end)

      #     _otherwise ->
      #       ["No actions"]
      #   end

      # # NOTE - I automatically assumed moving things around in this `blocks` list would move them in the UI - and that's a normal good assumptioni!
      # # actually nothying moved because the frames need to be updated, but it would hgave been cooler if the framework understood what I means when I moved the blocks around

      #
      # first_f = Widgex.Frame.new(%{size: {f.size.width, panel_h}, pin: {0, title_h}})
      # second_f = Widgex.Frame.new(%{size: {f.size.width, panel_h}, pin: {0, title_h + panel_h}})

      # third_f =
      #   Widgex.Frame.new(%{size: {f.size.width, panel_h}, pin: {0, title_h + 2 * panel_h}})

      # fourth_f_big =
      #   Widgex.Frame.new(%{size: {f.size.width, 2 * panel_h}, pin: {0, title_h + 3 * panel_h}})

      # # extra pin height cause fourth frame is so big
      # fifth_f =
      #   Widgex.Frame.new(%{size: {f.size.width, panel_h}, pin: {0, title_h + 5 * panel_h}})



    case Scenic.Graph.get(graph, @todo_details) do
      [] ->
        graph
        |> Scenic.Primitives.group(fn graph ->
          graph
          |> render_todo_details(frame, state)
        end, id: @todo_details)

      _primitive ->
        graph
        |> render_todo_details(frame, state)
    end
  end

  defp render_todo_details(graph, frame, state) do
    graph
    |> render_background(frame)
    |> render_todo_components(frame, state)
  end

  @background :background
  defp render_background(graph, frame) do
    case Scenic.Graph.get(graph, @background) do
      [] ->
        graph
        |> Scenic.Primitives.rect(
          frame.size.box,
          fill: @background_color,
          translate: frame.pin.point
          )

      _primitive ->
        # for now do nothing, could potentially call Graph.modify here though
        graph
    end
  end


  # wraps everything in a vertical list for scrolling purposes
  @todo_component_list :todo_component_list
  defp render_todo_components(graph, frame, state) do
    case Scenic.Graph.get(graph, @todo_component_list) do
      [] ->

        title_h  = 60
        panel_h  = 420
        header_f = Widgex.Frame.new(%{size: {frame.size.width, title_h}, pin: {0, 0}})
        first_f  = Widgex.Frame.new(%{size: {frame.size.width, panel_h}, pin: {0, title_h}})
        second_f  = Widgex.Frame.new(%{size: {frame.size.width, panel_h*2}, pin: {0, title_h + panel_h}})

        blocks = [
          {ScenicWidgets.Markup.Header1, %{frame: header_f, text: state.tidbit.title}},
          {draw_tiles_fn(), %{frame: first_f, state: state}},
          {draw_timeline_fn(), %{frame: second_f, state: state}}

          # # {draw_data_fn(), %{frame: first_f, tidbit: t}},
          # # priority, due/planned date, status, tags, labels, notes, history
          # {draw_data_fn(), %{frame: first_f, state: state}},
          # {draw_action_list_fn(), %{frame: second_f, actions: tidbit_actions}},
          # {draw_hist_fn(), %{frame: third_f, tidbit: t}},
          # {draw_raw_tidbit, %{frame: fourth_f_big}},
          # {draw_hist_fn(), %{frame: fifth_f, tidbit: t}}
        ]

        #TODO I guess we need to pass things down to vertical list, like when frames change :(
        graph
        |> Scenic.Primitives.group(
          fn graph ->
            graph
            # TODO pass this a function, which will evaluate to the graph to
            # wrap inside the Vertical list - then we can keep building out the graph naturally here, instead of having to pass in blocks
            #
            #  e.g.
            #
            #  VierticalList.add_to_graph(
            #     frame: frame, scroll: scroll, graph_fn: fn -> base_graph |> Scenic.Primitives.rect(....)
            #
            #)
            |> ScenicWidgets.VerticalList.add_to_graph(%{
              id: {TODOdetails, state.tidbit.uuid},
              # id: @todo_component_list,
              frame: frame,
              items: blocks,
              scroll: state.scroll
            })
          end,
          id: @todo_component_list,
          translate: frame.pin.point
        )

      _primitive ->
        # for now do nothing, could potentially call Graph.modify here though
        graph
    end
  end

  defp draw_timeline_fn do
    fn graph, %{frame: frame, state: %{tidbit: tidbit}} ->

      IO.inspect(frame, label: "BIG FRAME")

      # Define the grid with two equal columns and one row
      grid =
        Widgex.Frame.Grid.new(frame)
        #TODO there's a bug here where if we pass [1] for rows it doesn't calculate height correctly
        |> Widgex.Frame.Grid.rows([9/10, 1/10])               # Single row
        |> Widgex.Frame.Grid.columns([1/2, 1/2])    # Two equal columns
        |> Widgex.Frame.Grid.define_areas(%{
          left_box: {0, 0, 1, 1},    # Entire left column
          right_box: {0, 1, 1, 1}    # Entire right column
        })

      # Calculate the frames for the grid
      cell_frames = Widgex.Frame.Grid.calculate(grid)

      # Extract individual frames
      left_box_frame = Widgex.Frame.Grid.area_frame(grid, cell_frames, :left_box)
      right_box_frame = Widgex.Frame.Grid.area_frame(grid, cell_frames, :right_box)

      # Render tiles for each frame
      graph
      |> render_rounded_tile(left_box_frame, %{line1: "Timeline", line2: "Unknown"})
      |> render_rounded_tile(right_box_frame, %{line1: "Sub-tasks", line2: "No sub-tasks"})
    end
  end

  defp draw_tiles_fn do

    # due date
    # status
    # planned date
    # priority

    fn
      graph, %{frame: frame, state: %{tidbit: tidbit}} = args ->

        # grid =
        #   Widgex.Frame.Grid.new(frame)
        #   # Two rows, each taking 50% of the height
        #   |> Widgex.Frame.Grid.rows([0.5, 0.5])
        #   # Three columns, each taking 33.33% of the width
        #   |> Widgex.Frame.Grid.columns([1/3, 1/3, 1/3])
        #   # Define areas for a 3x2 grid
        #   |> Widgex.Frame.Grid.define_areas(%{
        #     top_left: {0, 0, 1, 1},
        #     top_middle: {0, 1, 1, 1},
        #     top_right: {0, 2, 1, 1},
        #     bottom_left: {1, 0, 1, 1},
        #     bottom_middle: {1, 1, 1, 1},
        #     bottom_right: {1, 2, 1, 1}
        #   })

        # cell_frames = Widgex.Frame.Grid.calculate(grid)
        # top_left_frame = Widgex.Frame.Grid.area_frame(grid, cell_frames, :top_left)
        # top_middle_frame = Widgex.Frame.Grid.area_frame(grid, cell_frames, :top_middle)
        # top_right_frame = Widgex.Frame.Grid.area_frame(grid, cell_frames, :top_right)
        # bottom_left_frame = Widgex.Frame.Grid.area_frame(grid, cell_frames, :bottom_left)
        # bottom_right_frame = Widgex.Frame.Grid.area_frame(grid, cell_frames, :bottom_right)
        # bottom_middle_frame = Widgex.Frame.Grid.area_frame(grid, cell_frames, :bottom_middle)

        # row_specs = [1] # Full height for the left column
        # column_specs = [5/7, 2/7]
        # area_definitions = %{
        #   left_box: {0, 0, 1, 1},
        #   right_top: {0, 1, 0.25, 1},
        #   right_upper_middle: {0.25, 1, 0.25, 1},
        #   right_lower_middle: {0.5, 1, 0.25, 1},
        #   right_bottom: {0.75, 1, 0.25, 1}
        # }

        # grid_rows = 4 # For dividing the right column into 4 rows
        # grid_cols = 7 # For dividing the grid width into 7 columns (5 for left, 2 for right)


        # row_specs = [0.5, 0.5]
        # column_specs = [1/3, 1/3, 1/3]
        # area_definitions = %{
        #   # left_box: {0, 0, grid_rows, 5}, # Entire left column (5/7 of width)
        #   # right_top: {0, 5, 1, 2},        # Top row of the right column (2/7 of width)
        #   # right_upper_middle: {1, 5, 1, 2}, # Second row of the right column
        #   # right_lower_middle: {2, 5, 1, 2}, # Third row of the right column
        #   # right_bottom: {3, 5, 1, 2}        # Bottom row of the right column
        #     top_left: {0, 0, 1, 1},
        #     top_middle: {0, 1, 1, 1},
        #     top_right: {0, 2, 1, 1},
        #     bottom_left: {1, 0, 1, 1},
        #     bottom_middle: {1, 1, 1, 1},
        #     bottom_right: {1, 2, 1, 1}
        # }

        # row_specs = [1, 1] # 2 equal rows
        # column_specs = [2/3, 1/3] # 2/3 left column, 1/3 right column

        # # 0,0   0,1

        # # 1,0   1,1

        # area_definitions = %{
        #   left_box: {0, 0, 2, 1},    # Entire left column (spans both rows)
        #   right_top: {0, 1, 1, 1},   # Top box in the right column
        #   right_bottom: {1, 1, 1, 1} # Bottom box in the right column
        # }

        # grid_frames = Widgex.Frame.Grid.calculate_grid_frames(frame, row_specs, column_specs, area_definitions)

        # # Access specific frames
        # # left_box_frame = grid_frames[:left_box]
        # # right_top_frame = grid_frames[:right_top]

        # IO.inspect(grid_frames)

        # Define the grid manually

        grid =
          Widgex.Frame.Grid.new(frame)
          # Define 4 equal rows for vertical division of the right column
          |> Widgex.Frame.Grid.rows([1/4, 1/4, 1/4, 1/4])
          # Define 2 columns: 2/3 for the left and 1/3 for the right
          |> Widgex.Frame.Grid.columns([2/3, 1/3])
          # Define areas: left column and 4 sections in the right column
          |> Widgex.Frame.Grid.define_areas(%{
            left_box: {0, 0, 4, 1},            # Entire left column
            right_top: {0, 1, 1, 1},           # Top box in right column
            right_upper_middle: {1, 1, 1, 1},  # Second box in right column
            right_lower_middle: {2, 1, 1, 1},  # Third box in right column
            right_bottom: {3, 1, 1, 1}         # Bottom box in right column
          })

        # Calculate the frames for the grid
        cell_frames = Widgex.Frame.Grid.calculate(grid)

        # Extract the individual frames
        left_box_frame = Widgex.Frame.Grid.area_frame(grid, cell_frames, :left_box)
        right_top_frame = Widgex.Frame.Grid.area_frame(grid, cell_frames, :right_top)
        right_upper_middle_frame = Widgex.Frame.Grid.area_frame(grid, cell_frames, :right_upper_middle)
        right_lower_middle_frame = Widgex.Frame.Grid.area_frame(grid, cell_frames, :right_lower_middle)
        right_bottom_frame = Widgex.Frame.Grid.area_frame(grid, cell_frames, :right_bottom)

        # priority =
        #   case Memelex.TidBit.priority(tidbit) do
        #     nil ->
        #       "not assigned"

        #     x when is_integer(x) ->
        #       Integer.to_string(x)
        #   end


        graph
        # |> Scenic.Primitives.rect(
        #   top_left_frame.size.box,
        #   fill: :pink,
        #   translate: top_left_frame.pin.point
        # )
        |> render_data_section(left_box_frame, tidbit)
        # |> render_rounded_tile(right_top_frame, %{line1: "Status", line2: tidbit.status || "Unknown"})
        |> render_status(right_top_frame, tidbit)
        |> render_rounded_tile(right_upper_middle_frame, %{line1: "Planned date", line2: Memelex.TidBit.planned_date(tidbit, as: String) || "Unknown"})
        |> render_rounded_tile(right_lower_middle_frame, %{line1: "Due date", line2: Memelex.TidBit.due_date(tidbit, as: String) || "Unknown"})
        |> render_priority(right_bottom_frame, tidbit)


        # |> render_rounded_tile(grid_frames[:left_box_frame], %{line1: "Status", line2: tidbit.status || "Unknown"})
        # |> render_rounded_tile(grid_frames[:right_top_frame], %{line1: "Planned date", line2: Memelex.TidBit.planned_date(tidbit) || "Unknown"})
        # # |> render_rounded_tile(grid_frames[:top_right], %{line1: "Due date", line2: Memelex.TidBit.due_date(tidbit) || "Unknown"})
        # |> render_rounded_tile(grid_frames[:right_bottom], %{line1: "Priority", line2: Integer.to_string(Memelex.TidBit.priority(tidbit)) || "not assigned"})
        # |> Scenic.Primitives.rect(
        #   grid_frames[:bottom_right].size.box,
        #   fill: :purple,
        #   translate: grid_frames[:bottom_right].pin.point
        # )
    end
  end

  @in_progress "in_progress"
  @blocked "blocked"
  @done "done"
  @cancelled "cancelled"
  defp render_status(graph, frame, tidbit) do
    margin =  10
    radius =  10
    fill_color = nil
    text_color = :black
    font_size = 16

    # Calculate dimensions and positioning
    inner_width = frame.size.width - (margin * 2)
    inner_height = frame.size.height - (margin * 2)
    inner_x = frame.pin.x + margin
    inner_y = frame.pin.y + margin

    # Center text in the middle of the tile
    text_x = inner_x + (inner_width / 2)
    text_y_line1 = inner_y + (inner_height / 2) - (font_size / 2)
    text_y_line2 = inner_y + (inner_height / 2) + (font_size / 2)

    # dont pass fill as an option if we don't want to fill it
    rrect_opts =
      if is_nil(fill_color) do
        [stroke: {3, :black}, translate: {inner_x, inner_y}]
      else
        [stroke: {3, :black}, fill: fill_color, translate: {inner_x, inner_y}]
      end

    graph
    |> Scenic.Primitives.rrect(
      {inner_width, inner_height, radius},
      rrect_opts
    )
    |> Scenic.Primitives.text("Status",
          font_size: 24,
          fill: :black,
          # translate: {frame.size.width / 2, frame.size.height / 2}
          translate: {inner_x + 20, inner_y + 50}
        )
    |> ScenicWidgets.SpareParts.LukesDropDown.add_to_graph(
          {[
             {"unknown", nil},
             {@in_progress, @in_progress},
             {"done", "done"}, # TODO remove this eventually
            #  {"completed", "completed"},
            {"blocked", "blocked"},
             {"cancelled", "cancelled"}

          ], tidbit.status},
          id: {:status, tidbit.uuid},
          translate: {inner_x + 120, inner_y + 20}
        )
  end

  # defp calculate_grid_frames(frame, row_specs, column_specs, area_definitions) do
  #   # Create the grid
  #   grid =
  #     Widgex.Frame.Grid.new(frame)
  #     |> Widgex.Frame.Grid.rows(row_specs)
  #     |> Widgex.Frame.Grid.columns(column_specs)
  #     |> Widgex.Frame.Grid.define_areas(area_definitions)

  #   # Calculate all cell frames
  #   cell_frames = Widgex.Frame.Grid.calculate(grid)

  #   # Generate a map of frames for all defined areas
  #   area_definitions
  #   |> Map.keys()
  #   |> Enum.reduce(%{}, fn area_name, acc ->
  #     Map.put(acc, area_name, Widgex.Frame.Grid.area_frame(grid, cell_frames, area_name))
  #   end)
  # end

  defp render_priority(graph, frame, tidbit) do

    p = Memelex.TidBit.priority(tidbit) |> IO.inspect(label: "PRIORITY")

    margin =  10
    radius =  10
    fill_color = nil
    text_color = :black
    font_size = 16

    # Calculate dimensions and positioning
    inner_width = frame.size.width - (margin * 2)
    inner_height = frame.size.height - (margin * 2)
    inner_x = frame.pin.x + margin
    inner_y = frame.pin.y + margin

    # Center text in the middle of the tile
    text_x = inner_x + (inner_width / 2)
    text_y_line1 = inner_y + (inner_height / 2) - (font_size / 2)
    text_y_line2 = inner_y + (inner_height / 2) + (font_size / 2)

    # dont pass fill as an option if we don't want to fill it
    rrect_opts =
      if is_nil(fill_color) do
        [stroke: {3, :black}, translate: {inner_x, inner_y}]
      else
        [stroke: {3, :black}, fill: fill_color, translate: {inner_x, inner_y}]
      end

    graph
    |> Scenic.Primitives.rrect(
      {inner_width, inner_height, radius},
      rrect_opts
    )
    |> Scenic.Primitives.text("Priority",
          font_size: 24,
          fill: :black,
          # translate: {frame.size.width / 2, frame.size.height / 2}
          translate: {inner_x + 20, inner_y + 50}
        )
    |> ScenicWidgets.SpareParts.LukesDropDown.add_to_graph(
          {[
             {"Not assigned", :not_assigned},
            #  {"0", 0}, # TODO remove this eventually
             {"1", 1},
             {"2", 2},
             {"3", 3},
             {"5", 5},
             {"8", 8},
             {"12", 12},
             {"21", 21},
             {"34", 34},
             {"55", 55},
             {"89", 89},
             {"144", 144},
             {"233", 233},
             {"377", 377},
             {"610", 610}
            #  {"This month", :this_month},
            #  #  {"Next month", :next_month},
            #  #  {"Most urgent", :most_urgent},
            #  {"Overdue", :overdue},
            #  {"Newest 20", {:newest, 20}},
            #  {"Oldest 20", {:oldest, 20}},
            #  {"Random 20", {:random, 20}}
             #  {"By Priority", :priority},
             #  {"Top Ten", :top_ten},
             #  {"Soonest deadline", :soonest},
             #  {"Un-prioritized", :un_prioritized},
             #  {"Done", :done},
          ], default_priority(p)},
          id: {:priority, tidbit.uuid},
          translate: {inner_x + 120, inner_y + 20}
        )
  end

  def default_priority(priority) do
    case priority do
      # 0 ->
      #   IO.puts "GOT A PRIORITY OF ZERO I DONT LIKE IT"
      #   1

      p when is_integer(p) ->
        p

      aaa ->
        IO.puts "GOT WEIRD PRIORITY #{inspect aaa}"
        :not_assigned
    end
  end

  # |> ScenicWidgets.SpareParts.LukesDropDown.add_to_graph(
  #         {[
  #            {"All", :all},
  #            {"This week", :this_week},
  #            {"This month", :this_month},
  #            #  {"Next month", :next_month},
  #            #  {"Most urgent", :most_urgent},
  #            {"Overdue", :overdue},
  #            {"Newest 20", {:newest, 20}},
  #            {"Oldest 20", {:oldest, 20}},
  #            {"Random 20", {:random, 20}}
  #            #  {"By Priority", :priority},
  #            #  {"Top Ten", :top_ten},
  #            #  {"Soonest deadline", :soonest},
  #            #  {"Un-prioritized", :un_prioritized},
  #            #  {"Done", :done},
  #          ], default},
  #         id: :filter_select,
  #         translate: {20, 20}
  #       )

  defp render_due_date(graph, frame, tidbit) do
    %{meta: [meta_map]} = tidbit

    due_date = meta_map["due_date"] || meta_map[:due_data] || "Unknown"

    graph
    |> Scenic.Primitives.rect(
        frame.size.box,
        fill: :orange,
        translate: frame.pin.point
      )
      |> Scenic.Primitives.text(
        # tidbit.due_date,
        "DUE DATE",
        font_size: 16, # Adjust size for readability
        # fill: :white, # Contrasting color for text
        translate: {
          frame.pin.x + frame.size.width / 2 - 40, # Center the text horizontally
          frame.pin.y + frame.size.height / 2 + 8  # Center the text vertically
        },
        text_align: :center
      )
    |> Scenic.Primitives.text(
      # tidbit.due_date,
      due_date,
      font_size: 16, # Adjust size for readability
      # fill: :white, # Contrasting color for text
      translate: {
        frame.pin.x + frame.size.width / 2 - 40, # Center the text horizontally
        frame.pin.y + frame.size.height / 2 + 28  # Center the text vertically
      },
      text_align: :center
    )
  end

  defp render_rounded_tile(graph, frame, params) do
    # Extract parameters with defaults
    # IO.inspect(params)

    margin = params[:margin] || 10
    radius = params[:radius] || 10
    fill_color = params[:fill_color] || nil
    text_color = params[:text_color] || :black
    line1 = params[:line1] || "Line 1"
    line2 = params[:line2] || "Line 2 VVVVVV"
    font_size = params[:font_size] || 16

    # Calculate dimensions and positioning
    inner_width = frame.size.width - (margin * 2)
    inner_height = frame.size.height - (margin * 2)
    inner_x = frame.pin.x + margin
    inner_y = frame.pin.y + margin

    # Center text in the middle of the tile
    text_x = inner_x + (inner_width / 2)
    text_y_line1 = inner_y + (inner_height / 2) - (font_size / 2)
    text_y_line2 = inner_y + (inner_height / 2) + (font_size / 2)

    # dont pass fill as an option if we don't want to fill it
    rrect_opts =
      if is_nil(fill_color) do
        [stroke: {3, :black}, translate: {inner_x, inner_y}]
      else
        [stroke: {3, :black}, fill: fill_color, translate: {inner_x, inner_y}]
      end

    graph
    |> Scenic.Primitives.rrect(
      {inner_width, inner_height, radius},
      rrect_opts
    )
    |> Scenic.Primitives.text(
      line1,
      font_size: font_size,
      fill: text_color,
      translate: {text_x, text_y_line1},
      text_align: :center
    )
    |> Scenic.Primitives.text(
      line2,
      font_size: font_size,
      fill: text_color,
      translate: {text_x, text_y_line2},
      text_align: :center
    )
  end

  defp render_data_section(graph, frame, tidbit) do
    # Extract parameters with defaults
    # IO.inspect(params)

    margin =  10
    radius =  10
    fill_color = nil
    text_color = :black
    font_size = 16

    # Calculate dimensions and positioning
    inner_width = frame.size.width - (margin * 2)
    inner_height = frame.size.height - (margin * 2)
    inner_x = frame.pin.x + margin
    inner_y = frame.pin.y + margin

    # Center text in the middle of the tile
    text_x = inner_x + (inner_width / 2)
    text_y_line1 = inner_y + (inner_height / 2) - (font_size / 2)
    text_y_line2 = inner_y + (inner_height / 2) + (font_size / 2)

    # dont pass fill as an option if we don't want to fill it
    rrect_opts =
      if is_nil(fill_color) do
        [stroke: {3, :black}, translate: {inner_x, inner_y}]
      else
        [stroke: {3, :black}, fill: fill_color, translate: {inner_x, inner_y}]
      end

    text =
      case tidbit.data do
        nil ->
          "No data"

        "" ->
          "No data"

        d when is_binary(d) ->
          d
      end

    graph
    |> Scenic.Primitives.rrect(
      {inner_width, inner_height, radius},
      rrect_opts
    )
    |> Scenic.Primitives.text(
      text,
      font_size: font_size,
      fill: text_color,
      translate: {text_x, text_y_line1},
      text_align: :center
    )
    # |> Scenic.Primitives.text(
    #   line2,
    #   font_size: font_size,
    #   fill: text_color,
    #   translate: {text_x, text_y_line2},
    #   text_align: :center
    # )
  end

  # def draw_data_fn do
  #   fn
  #     graph, %{frame: f, state: %{tidbit: t, edit_description?: false}} = args ->
  #       # IO.puts("ARE WE ALWAYS HERE???")

  #       graph
  #       |> draw_neo_card_background(f)
  #       |> Memelex.GUI.Components.IconButton.add_to_graph(
  #         %{
  #           frame: Widgex.Frame.new(pin: {10, 10}, size: {50, 50}),
  #           icon: "ionicons/black_32/edit.png"
  #         },
  #         id: {:edit, t.uuid},
  #         # need to move it back twice the width because we're right aligning now
  #         translate: {f.size.width - 20 - 50 - 50, f.pin.y + 5}
  #       )
  #       |> Scenic.Primitives.text(t.data,
  #         font: :ibm_plex_mono,
  #         font_size: 24,
  #         fill: :white,
  #         translate: {f.pin.x + 20, f.pin.y + 20 + 20 + 60}
  #       )

  #     graph, %{frame: f, state: %{tidbit: t, edit_description?: true}} = args ->
  #       IO.puts("EDITING THE DESC")

  #       graph
  #       |> draw_neo_card_background(f)
  #       |> Memelex.GUI.Components.IconButton.add_to_graph(
  #         %{
  #           frame: Widgex.Frame.new(pin: {10, 10}, size: {50, 50}),
  #           icon: "ionicons/black_32/save.png"
  #         },
  #         id: {:save, t.uuid},
  #         # need to move it back twice the width because we're right aligning now
  #         translate: {f.size.width - 20 - 50 - 50, f.pin.y + 5}
  #       )
  #       # |> Scenic.Primitives.text(t.data,
  #       #   font: :ibm_plex_mono,
  #       #   font_size: 24,
  #       #   fill: :white,
  #       #   translate: {f.pin.x + 20, f.pin.y + 20 + 20 + 60}
  #       # )

  #       # |> Scenic.Component.Input.TextField.add_to_graph(
  #       #   "Some test text",
  #       #   id: {:data, t.uuid},
  #       #   # translate: f.pin.point
  #       #   translate: {f.pin.x + 20, f.pin.y + 20 + 60}
  #       # )

  #       # |> ScenicWidgets.TextPad.add_to_graph(
  #       #   %{
  #       #     frame:
  #       #       Widgex.Frame.new(
  #       #         pin: {10, 10 + 60},
  #       #         size: {f.size.width - 20, f.size.height - 20 - 60}
  #       #       ),
  #       #     state:
  #       #       ScenicWidgets.TextPad.new(%{
  #       #         # mode: :read_only,
  #       #         mode: :edit,
  #       #         text: t.data,
  #       #         font: body_font()
  #       #       })
  #       #   },
  #       #   id: {:data, t.uuid},
  #       #   # translate: {f.pin.x, f.pin.y}
  #       #   translate: f.pin.point
  #       # )
  #   end
  # end

  # def body_font do
  #   # TODO dont do this here, pass it in from the config

  #   # TODO...
  #   {:ok, ibm_plex_mono_font_metrics} =
  #     TruetypeMetrics.load("./assets/fonts/IBM_Plex_Mono/IBMPlexMono-Regular.ttf")

  #   # TODO make this more efficient, pass it in same everywhere
  #   ascent = FontMetrics.ascent(36, ibm_plex_mono_font_metrics)

  #   %{
  #     name: :ibm_plex_mono,
  #     size: 24,
  #     metrics: ibm_plex_mono_font_metrics,
  #     ascent: ascent
  #   }
  # end

  # # def draw_neo_card_background(graph, f) do
  # #   radius = 20

  # #   graph
  # #   # Fill the box with color
  # #   |> Scenic.Primitives.rrect(
  # #     {f.size.width - 20, f.size.height - 20, radius},
  # #     fill: :black,
  # #     translate: {f.pin.x + 10, f.pin.y + 10}
  # #   )
  # #   |> Scenic.Primitives.rrect(
  # #     {f.size.width - 20, f.size.height - 20, radius},
  # #     stroke: {4, :blue},
  # #     fill: :transparent,
  # #     translate: {f.pin.x + 10, f.pin.y + 10}
  # #   )
  # # end

  # def draw_neo_card_background(graph, f) do
  #   radius = 20
  #   header_height = 60
  #   heading = "description"
  #   # Adjust the text size as needed
  #   text_size = 24

  #   # Calculate the coordinates for centering the text
  #   text_x = f.pin.x + f.size.width / 2 - String.length(heading) * text_size / 4
  #   text_y = f.pin.y + header_height / 2 + text_size / 2 + 10

  #   graph
  #   # Fill the main card body with black
  #   |> Scenic.Primitives.rrect(
  #     {f.size.width - 20, f.size.height - 20, radius},
  #     fill: :black,
  #     translate: {f.pin.x + 10, f.pin.y + 10}
  #   )
  #   # Fill the header section with grey
  #   |> Scenic.Primitives.rrect(
  #     {f.size.width - 20, header_height, radius},
  #     fill: :grey,
  #     translate: {f.pin.x + 10, f.pin.y + 10}
  #   )
  #   # Stroke the card with a blue border
  #   |> Scenic.Primitives.rrect(
  #     {f.size.width - 20, f.size.height - 20, radius},
  #     stroke: {4, :blue},
  #     fill: :transparent,
  #     translate: {f.pin.x + 10, f.pin.y + 10}
  #   )
  #   # Draw a blue line under the header
  #   |> Scenic.Primitives.line(
  #     {{f.pin.x + 10, f.pin.y + 10 + header_height},
  #      {f.pin.x + f.size.width - 10, f.pin.y + 10 + header_height}},
  #     stroke: {2, :blue}
  #   )
  #   # Add centered text in the header
  #   |> Scenic.Primitives.text(
  #     heading,
  #     font_size: text_size,
  #     # You can change this to another color if needed
  #     fill: :white,
  #     translate: {text_x, text_y}
  #   )
  # end

  # def draw_card_background(graph, %Widgex.Frame{} = f) do
  #   graph
  #   |> Scenic.Primitives.rect(
  #     f.size.box,
  #     fill: :grey,
  #     translate: f.pin.point
  #   )
  #   |> Scenic.Primitives.rrect(
  #     {f.size.width - 20, f.size.height - 20, 20},
  #     stroke: {2, :grey},
  #     fill: :transparent,
  #     translate: {f.pin.x + 10, f.pin.y + 10}
  #   )
  #   # Fill the box with color
  #   |> Scenic.Primitives.rrect(
  #     {f.size.width - 20, f.size.height - 20, 20},
  #     fill: :black,
  #     translate: {f.pin.x + 10, f.pin.y + 10}
  #   )
  # end

  # def draw_hist_fn do
  #   fn graph, %{frame: f, tidbit: t} = args ->
  #     # reverse history so that the most recent updates render up the top
  #     bullets =
  #       if is_nil(t.history) do
  #         []
  #       else
  #         t.history
  #         # sometimes history is a binary, sometimes it's a map
  #         |> Enum.map(fn
  #           h_log when is_binary(h_log) ->
  #             h_log

  #           %{"timestamp" => ts, "log" => log} ->
  #             ts <> "\n" <> log
  #         end)
  #         |> Enum.reverse()
  #       end

  #     graph
  #     |> draw_basic_card(f, %{header: "History", bullets: bullets})
  #   end
  # end

  # def draw_basic_card(graph, %Widgex.Frame{} = f, %{header: h_text, bullets: bullets}) do
  #   # header_text = "History"
  #   header_font_size = 32

  #   box_width = f.size.width
  #   center_x = f.pin.x + box_width / 2

  #   # hack because sometimes history can be nil, even though it isn't supposed to be it should always be an empty list, but some old memexes have it...
  #   bullets = bullets || []

  #   graph
  #   |> Scenic.Primitives.rect(
  #     f.size.box,
  #     fill: :grey,
  #     translate: f.pin.point
  #   )
  #   |> Scenic.Primitives.rrect(
  #     {f.size.width - 20, f.size.height - 20, 20},
  #     stroke: {2, :grey},
  #     fill: :transparent,
  #     translate: {f.pin.x + 10, f.pin.y + 10}
  #   )
  #   # Fill the box with color
  #   |> Scenic.Primitives.rrect(
  #     {f.size.width - 20, f.size.height - 20, 10},
  #     fill: :black,
  #     translate: {f.pin.x + 10, f.pin.y + 10}
  #   )
  #   # Draw the centered header text
  #   |> Scenic.Primitives.text(h_text,
  #     font: :ibm_plex_mono,
  #     font_size: header_font_size,
  #     fill: :white,
  #     translate: {center_x, f.pin.y + 50},
  #     text_align: :center
  #   )
  #   # Add the bullet-pointed action list
  #   |> draw_bullet_points(f, bullets)
  # end

  # def draw_action_list_fn do
  #   fn graph, %{frame: f, actions: actions} = args ->
  #     # Calculate the center for the header text
  #     header_text = "Action List"
  #     header_font_size = 32

  #     box_width = f.size.width
  #     center_x = f.pin.x + box_width / 2

  #     # Draw the outer round-rectangle with margin
  #     graph
  #     |> Scenic.Primitives.rect(
  #       f.size.box,
  #       fill: :grey,
  #       translate: f.pin.point
  #     )
  #     |> Scenic.Primitives.rrect(
  #       {f.size.width - 20, f.size.height - 20, 20},
  #       stroke: {2, :grey},
  #       fill: :transparent,
  #       translate: {f.pin.x + 10, f.pin.y + 10}
  #     )
  #     # Fill the box with color
  #     |> Scenic.Primitives.rrect(
  #       {f.size.width - 20, f.size.height - 20, 10},
  #       fill: :black,
  #       translate: {f.pin.x + 10, f.pin.y + 10}
  #     )
  #     # Draw the centered header text
  #     |> Scenic.Primitives.text(header_text,
  #       font: :ibm_plex_mono,
  #       font_size: header_font_size,
  #       fill: :white,
  #       translate: {center_x, f.pin.y + 50},
  #       text_align: :center
  #     )
  #     # Add the bullet-pointed action list
  #     |> draw_bullet_points(f, actions)
  #   end
  # end

  # defp draw_bullet_points(graph, frame, lines) when is_list(lines) do
  #   # Starting y-position below the header
  #   start_y = frame.pin.y + 90
  #   # Adjust space between bullet points
  #   bullet_spacing = 90

  #   Enum.reduce(lines, graph, fn ln, g ->
  #     bullet_y = start_y + bullet_spacing * Enum.find_index(lines, fn x -> x == ln end)

  #     g
  #     # small circle for bullet point
  #     |> Scenic.Primitives.circle(5,
  #       fill: :white,
  #       # Position for the bullet point
  #       translate: {frame.pin.x + 20, bullet_y - 9}
  #     )
  #     |> Scenic.Primitives.text(ln,
  #       font: :ibm_plex_mono,
  #       font_size: 24,
  #       fill: :white,
  #       # Position for the text next to the bullet point
  #       translate: {frame.pin.x + 35, bullet_y}
  #     )
  #   end)
  # end

  # def old_render(graph, %{
  #       frame: %Widgex.Frame{} = f,
  #       state: %Memelex.TidBit{} = t
  #     }) do
  #   graph
  #   |> render_raw_tidbit(f, t)
  #   |> render_tools(f)
  # end

  # def render_raw_tidbit(graph, frame, %Memelex.TidBit{} = t) do
  #   graph
  #   |> Scenic.Primitives.group(
  #     fn graph ->
  #       graph
  #       # |> Widgex.Frame.draw_guidewires(f, color: :purple)
  #       |> Scenic.Primitives.text("#{prettify_map(t)}",
  #         font: :ibm_plex_mono,
  #         font_size: 24,
  #         fill: :white,
  #         translate: {20, 50}
  #       )
  #     end,
  #     translate: frame.pin.point
  #   )
  # end

  # @spacing 180
  # def render_tools(graph, %Widgex.Frame{} = f) do
  #   graph
  #   |> Scenic.Primitives.group(
  #     fn graph ->
  #       graph
  #       |> Scenic.Components.button("Lower priority", id: :lower_priority, t: {10, 10})
  #       |> Scenic.Components.button("Higher priority",
  #         id: :higher_priority,
  #         t: {10 + @spacing, 10}
  #       )
  #       |> Scenic.Components.button("Add Due date",
  #         id: :sample_btn_id,
  #         t: {10 + 2 * @spacing, 10}
  #       )
  #       |> Scenic.Components.button("Consequences",
  #         id: :sample_btn_id,
  #         t: {10 + 3 * @spacing, 10}
  #       )
  #       ## next row
  #       |> Scenic.Components.button("Create sub-task", id: :sample_btn_id, t: {10, 60})
  #       |> Scenic.Components.button("Blockers", id: :sample_btn_id, t: {10 + 1 * @spacing, 60})
  #       |> Scenic.Components.button("Req'd resources",
  #         id: :sample_btn_id,
  #         t: {10 + 2 * @spacing, 60}
  #       )
  #       |> Scenic.Components.button("Apply label",
  #         id: :sample_btn_id,
  #         t: {10 + 3 * @spacing, 60}
  #       )
  #       ## next row
  #       |> Scenic.Components.button("Last movement", id: :sample_btn_id, t: {10, 110})
  #       |> Scenic.Components.button("Next action", id: :sample_btn_id, t: {10 + 1 * @spacing, 110})
  #     end,
  #     # translate: {20, f.size.height - 200}
  #     translate: {f.pin.x + 20, f.pin.y + f.size.height - 200}
  #   )
  #   # close button
  #   |> Scenic.Components.button("Close", id: :close, t: {450, 20})
  # end

  # def prettify_map(map) when is_map(map) do
  #   map
  #   |> Inspect.Algebra.to_doc(%Inspect.Opts{pretty: true, width: 80})
  #   |> Inspect.Algebra.format(80)
  #   |> IO.iodata_to_binary()
  # end
end
