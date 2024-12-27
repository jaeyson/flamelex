defmodule Flamelex.GUI.Component.AgentHuddle.Render do
  alias Flamelex.GUI.Component.AgentHuddle
  alias Flamelex.GUI.Utils.Draw
  alias Widgex.Frame
  alias Widgex.Frame.Grid
  alias Scenic.Graph
  alias Scenic.Primitives
  alias Flamelex.GUI.Component.CodeBlock

  def render(
    %Scenic.Graph{} = graph,
    %Widgex.Frame{} = frame,
    %AgentHuddle.State{} = state
  ) do
        # Define a grid that splits the frame into two equal columns
        grid =
          Grid.new(frame)
          # Single row taking 100% of the height
          |> Grid.rows([1.0])
          # Two columns, each 50% of the width
          |> Grid.columns([0.5, 0.5])
          |> Grid.define_areas(%{
            left_half: {0, 0, 1, 1},
            right_half: {0, 1, 1, 1}
          })

        # Calculate the frames for each grid area
        cell_frames = Grid.calculate(grid)
        left_frame = Grid.area_frame(grid, cell_frames, :left_half)
        right_frame = Grid.area_frame(grid, cell_frames, :right_half)

        # Build the graph with the new layout
        # graph =
        graph
        |> render_left_half(left_frame, state)
        |> render_right_half(right_frame, state)

        # graph
  end

  # def go(%Widgex.Frame{} = frame, %AgentHuddle.State{} = state) do
  #   # Define a grid that splits the frame into two equal columns
  #   grid =
  #     Grid.new(frame)
  #     # Single row taking 100% of the height
  #     |> Grid.rows([1.0])
  #     # Two columns, each 50% of the width
  #     |> Grid.columns([0.5, 0.5])
  #     |> Grid.define_areas(%{
  #       left_half: {0, 0, 1, 1},
  #       right_half: {0, 1, 1, 1}
  #     })

  #   # Calculate the frames for each grid area
  #   cell_frames = Grid.calculate(grid)
  #   left_frame = Grid.area_frame(grid, cell_frames, :left_half)
  #   right_frame = Grid.area_frame(grid, cell_frames, :right_half)

  #   # Build the graph with the new layout
  #   graph =
  #     Graph.build()
  #     |> Primitives.group(
  #       fn graph ->
  #         graph
  #         # |> Draw.background(frame, :rebecca_purple)
  #         # |> Widgex.Frame.draw_guidewires(frame)
  #         |> render_left_half(left_frame, state)
  #         |> render_right_half(right_frame, state)
  #       end
  #       # translate: frame.pin.point
  #     )

  #   graph
  # end

  # Render content in the left half
  defp render_left_half(graph, %Frame{} = frame, %AgentHuddle.State{} = state) do
    # 1. Draw a background over the left half
    # graph =
    #   graph
    #   |> Draw.background(frame, :dark_blue)
    #   |> Widgex.Frame.draw_guidewires(frame)

    # 3. Define a grid within the inner_frame
    grid =
      Grid.new(frame)
      |> Grid.rows([0.04, 0.92, 0.04])
      |> Grid.columns([0.04, 0.92, 0.04])
      |> Grid.define_areas(%{
        editor_area: {1, 1, 1, 1}
      })

    # Calculate the frames for the grid areas
    cell_frames = Grid.calculate(grid)
    editor_frame = Grid.area_frame(grid, cell_frames, :editor_area)

    # TODO there's some fuckiness with how frames get placed when
    # the outer frame is translated, I think we need to not include
    # the old pin in our Grid frames but it's complex, so hacking it for now

    # TODO this is hacky but fuck it I need the memex env here...
    memex_env = Flamelex.Fluxus.RadixStore.get().memex.env

    agent_file = Memelex.Utils.AgentUtils.full_agent_filepath(memex_env, state.tidbit.data)
    {:ok, agent_code} = File.read(agent_file)

    graph
    |> CodeBlock.add_to_graph(%{
      frame: editor_frame,
      state:
        CodeBlock.State.new(%{
          title: agent_file,
          text: agent_code
        })
    })
    |> render_activate_deactivate_btn(frame, state)
  end

  def render_activate_deactivate_btn(graph, frame, %{tidbit: %{data: %{status: :active}}} = state) do
    # delete it just in case
    graph = Scenic.Graph.delete(graph, :activate_agent_btn)

    case Scenic.Graph.get(graph, :deactivate_agent_btn) do
      [] ->
        graph
        |> Scenic.Components.button(
          "De-activate",
          id: :deactivate_agent_btn,
          width: 100,
          # background: :green,
          # fill: :green,
          theme: :warning,
          height: 30,
          translate: {frame.pin.x + 120, frame.pin.y + frame.size.height - 130}
        )

      _primitive ->
        graph
    end
  end

  def render_activate_deactivate_btn(graph, frame, state) do
    # delete it just in case
    graph = Scenic.Graph.delete(graph, :deactivate_agent_btn)

    case Scenic.Graph.get(graph, :activate_agent_btn) do
      [] ->
        graph
        |> Scenic.Components.button(
          "Activate",
          id: :activate_agent_btn,
          width: 100,
          background: :green,
          fill: :green,
          theme: :success,
          height: 30,
          translate: {frame.pin.x + 120, frame.pin.y + frame.size.height - 130}
        )

      _primitive ->
        graph
    end
  end

  defp render_right_half(
    %Scenic.Graph{} = graph,
    %Widgex.Frame{} = frame,
    %AgentHuddle.State{} = state
  ) do
    case Scenic.Graph.get(graph, :right_half) do
      [] ->
        graph
        |> Scenic.Primitives.group(fn graph ->
          do_render_right_half(graph, frame, state)
        end, id: :right_half)

      _primitive ->
        do_render_right_half(graph, frame, state)
    end
  end

  # TODO have tab bar selector up top, let us choose between chat, control panel & info (see TidBit)
  defp do_render_right_half(graph, frame, state) do
    graph
    |> render_right_half_background(frame, state)
    |> render_right_half_button_bar(frame, state)
    |> render_chat(frame, state)
    |> render_agent_settings(frame, state)
    |> render_agent_five_loop(frame, state)

    # IO.puts "========================"
    # IO.inspect g

    # g
  end

  defp render_right_half_background(
    %Scenic.Graph{} = graph,
    %Widgex.Frame{} = frame,
    %AgentHuddle.State{} = state
  ) do
    case Scenic.Graph.get(graph, :right_half_background) do
      [] ->
        graph
        |> Scenic.Primitives.rect(frame.size.box,
          id: :right_half_background,
          fill: :green,
          translate: frame.pin.point
        )

      _primitive ->
        # do nothing, maybe in future we change the color
        graph
    end
  end

  defp render_right_half_button_bar(
    %Scenic.Graph{} = graph,
    %Widgex.Frame{} = frame,
    %AgentHuddle.State{} = state
  ) do
    IO.puts "RENDER RIGHT BUTTON BAR"
    # Check if the button bar is already present in the graph
    case Scenic.Graph.get(graph, :right_half_button_bar) do
      [] ->
        # Create the button bar if it doesn't exist
        graph
        |> Scenic.Primitives.group(fn graph ->
          # Render individual buttons
          graph
          |> render_buttons(frame, state)
          # |> Scenic.Components.button(
          #   "Chat",
          #   id: :chat_window,
          #   width: 60,
          #   height: 30,
          #   translate: {frame.pin.x + 10, frame.pin.y + 10}
          # )
          # |> Scenic.Components.button(
          #   "Settings",
          #   id: :agent_settings,
          #   width: 100,
          #   height: 30,
          #   translate: {frame.pin.x + 80, frame.pin.y + 10}
          # )

        end, id: :right_half_button_bar)

      _primitive ->
        # Update the button bar if it already exists (e.g., state-dependent changes)
        # render_buttons(graph, frame, state)
        # IO.inspect(graph)
        graph
        #TODO why do we still need this? It's supposed to already exist in the graph...
        # |> render_buttons(frame, state)
    end
  end

  # TODO this one doesnt really update the bar right now, just re-draws it
  defp render_buttons(
    %Scenic.Graph{} = graph,
    %Widgex.Frame{} = frame,
    %AgentHuddle.State{} = state
  ) do
    IO.puts "RENDERING BUTTONZZZ"
      graph
      |> Scenic.Components.button(
        "Chat",
        id: :chat_window_btn,
        width: 60,
        height: 30,
        translate: {frame.pin.x + 10, frame.pin.y + 10}
      )
      |> Scenic.Components.button(
        "Settings",
        id: :agent_settings_btn,
        width: 100,
        height: 30,
        translate: {frame.pin.x + 80, frame.pin.y + 10}
      )
      |> Scenic.Components.button(
        "History Log",
        id: :agent_settings_btn,
        width: 120,
        height: 30,
        translate: {frame.pin.x + 200, frame.pin.y + 10}
      )
      |> Scenic.Components.button(
        "FIVE loop",
        id: :five_loop_btn,
        width: 100,
        height: 30,
        translate: {frame.pin.x + 340, frame.pin.y + 10}
      )


  #   # Example: Define button labels and actions
  #   button_specs = [
  #     %{label: "Chat", action: :select_chat},
  #     %{label: "Control", action: :select_control},
  #     %{label: "Info", action: :select_info}
  #   ]

  #   # Button dimensions and spacing
  #   button_width = 100
  #   button_height = 40
  #   button_spacing = 10

  #   # Starting position for the buttons
  #   {start_x, start_y} = frame.pin.point

  #   button_specs
  #   |> Enum.with_index()
  #   |> Enum.reduce(graph, fn {%{label: label, action: action}, index}, acc_graph ->
  #     x_offset = start_x + index * (button_width + button_spacing)

  #     acc_graph
  #     |> Scenic.Components.button(
  #       "Chat",
  #       id: :chat_window,
  #       width: 60,
  #       height: 30,
  #       translate: {frame.pin.x + 10, frame.pin.y + 10}
  #     )
  #     |> Scenic.Components.button(
  #       "Settings",
  #       id: :agent_settings,
  #       width: 100,
  #       height: 30,
  #       translate: {frame.pin.x + 80, frame.pin.y + 10}
  #     )
  #     # |> Scenic.Primitives.rect(
  #     #   {button_width, button_height},
  #     #   fill: :blue,
  #     #   translate: {x_offset, start_y},
  #     #   id: :"button_#{action}"
  #     # )
  #     # |> Scenic.Primitives.text(
  #     #   label,
  #     #   translate: {x_offset + 10, start_y + 10},
  #     #   fill: :white,
  #     #   font_size: 16,
  #     #   id: :"button_label_#{action}"
  #     # )
  #     # |> Scenic.Primitives.click(
  #     #   fn -> handle_button_click(action, state) end,
  #     #   id: :"button_click_#{action}"
  #     # )
  #   end)


  end

  defp render_chat(graph, frame, %{open_chat?: false} = state) do
    case Scenic.Graph.get(graph, :agent_chat) do
      [] ->
        graph
        # |> Scenic.Primitives.group(fn graph ->
        #   graph
        #   # |> render_buttons(frame, state)

        # end, id: :agent_chat)

      _primitive ->
        graph
        |> Scenic.Graph.delete(:agent_chat)
    end
  end

  defp render_chat(graph, frame, %{open_chat?: true} = state) do
    case Scenic.Graph.get(graph, :agent_chat) do
      [] ->
        graph
        |> Scenic.Primitives.group(fn graph ->
          graph
          |> Scenic.Primitives.rect(
            {200, 200},
            fill: :blue,
            translate: {frame.pin.x + 350, frame.pin.y + 50}
          )
        end, id: :agent_chat)

      _primitive ->
        graph
        # |> Scenic.Graph.delete(:agent_chat)
    end
  end

  defp render_agent_settings(graph, frame, %{open_agent_settings?: false} = state) do
    case Scenic.Graph.get(graph, :agent_settings) do
      [] ->
        graph
        # |> Scenic.Primitives.group(fn graph ->
        #   graph
        #   # |> render_buttons(frame, state)

        # end, id: :agent_chat)

      _primitive ->
        graph
        |> Scenic.Graph.delete(:agent_settings)
    end
  end

  defp render_agent_settings(graph, frame, %{open_agent_settings?: true} = state) do
    case Scenic.Graph.get(graph, :agent_settings) do
      [] ->
        graph
        |> Scenic.Primitives.group(fn graph ->
          graph
          |> Scenic.Primitives.rect(
            {600, 200},
            fill: :red,
            translate: {frame.pin.x + 350, frame.pin.y + 50}
          )
        end, id: :agent_settings)

      _primitive ->
        graph
        # |> Scenic.Graph.delete(:agent_chat)
    end
  end


  # defp handle_button_click(action, %AgentHuddle.State{} = state) do
  #   # Implement button click handling
  #   # Example: Update state or call a function
  #   IO.puts("Button clicked: #{action}")
  #   state
  # end


  defp render_agent_five_loop(graph, frame, %{open_agent_five_loop?: false} = state) do
    case Scenic.Graph.get(graph, :agent_five_loop) do
      [] ->
        # we're not supposed to show one and the graph doesn't have one :+1
        graph

      _primitive ->
        # we're not supposed to show one but it's there so delete it!
        graph
        |> Scenic.Graph.delete(:agent_five_loop)
    end
  end

  defp render_agent_five_loop(graph, frame, %{open_agent_five_loop?: true} = state) do
    offset = 240

    agent = state.tidbit.data

    case Scenic.Graph.get(graph, :agent_five_loop) do
      [] ->
        graph
        |> Scenic.Primitives.group(fn graph ->
          graph
          |> Scenic.Primitives.text("Status: #{inspect agent.status}, Phase: #{inspect agent.loop_phase}", id: :phase_status, translate: {frame.pin.x + 80, frame.pin.y + 120})
          |> Scenic.Primitives.rect(
            {900, 160},
            id: :perceive,
            fill: :turquoise,
            translate: {frame.pin.x + 80, frame.pin.y + offset}
          )
          |> Scenic.Primitives.text("Percepts: #{inspect agent.percepts}", id: :percepts, fill: :black, translate: {frame.pin.x + 80 + 15, frame.pin.y + offset + 15 + 30})
          |> Scenic.Primitives.rect(
            {900, 160},
            id: :deliberate,
            fill: :light_blue,
            translate: {frame.pin.x + 80, frame.pin.y + 180 + offset}
          )
          |> Scenic.Primitives.text("Plans: #{inspect agent.plans}", id: :plans, fill: :black, translate: {frame.pin.x + 80 + 15, frame.pin.y + offset + 180 + 15 + 30})
          |> Scenic.Primitives.rect(
            {900, 160},
            id: :plan,
            fill: :purple,
            translate: {frame.pin.x + 80, frame.pin.y + 2*180 + offset}
          )
          |> Scenic.Primitives.text("Results: #{inspect agent.results}", id: :results,  fill: :black, translate: {frame.pin.x + 80 + 15, frame.pin.y + offset + 2*180 + 15 + 30})
          |> Scenic.Primitives.rect(
            {900, 160},
            id: :execute,
            fill: :orange,
            translate: {frame.pin.x + 80, frame.pin.y + 3*180 + offset}
          )
          |> Scenic.Primitives.text("Evaluation: #{inspect agent.evaluation}", id: :evaluation, fill: :black, translate: {frame.pin.x + 80 + 15, frame.pin.y + offset + 3*180 + 15 + 30})
          |> Scenic.Components.button(
            "Nudge",
            id: :nudge_agent_btn,
            width: 120,
            height: 30,
            translate: {frame.pin.x + 220, frame.pin.y + 3*180 + offset + 300}
          )
        end, id: :agent_five_loop)

      _primitive ->
        # here we would modify an existing agent_five_loop if we wanted to
        graph
        |> Scenic.Graph.modify(:phase_status, &Scenic.Primitives.text(&1, "Status: #{inspect agent.status}, Phase: #{inspect agent.loop_phase}"))
        |> Scenic.Graph.modify(:percepts, &Scenic.Primitives.text(&1, "Percepts: #{inspect agent.percepts}"))
        |> Scenic.Graph.modify(:plans, &Scenic.Primitives.text(&1, "Plans: #{inspect agent.plans}"))
        |> Scenic.Graph.modify(:results, &Scenic.Primitives.text(&1, "Results: #{inspect agent.results}"))
        |> Scenic.Graph.modify(:evaluation, &Scenic.Primitives.text(&1, "Evaluation: #{inspect agent.evaluation}"))
    end
  end

  # defp do_render_agent_five_loop(graph, frame, state) do

  # end

end
