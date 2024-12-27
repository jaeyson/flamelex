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

end
