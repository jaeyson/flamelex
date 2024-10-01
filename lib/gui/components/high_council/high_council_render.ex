defmodule Flamelex.GUI.Component.HighCouncil.Render do
  @moduledoc """
  This module serves as a container for very complex render functions
  to avoid cluttering up the components.
  """
  alias Widgex.Frame
  alias Widgex.Frame.Grid
  alias Flamelex.GUI.Component.HighCouncil.State

  def go(%Frame{} = frame, %State{new_agent_mode?: new_agent_mode?} = state)
      when is_boolean(new_agent_mode?) do
    grid =
      Grid.new(frame)
      |> Grid.rows([0.10, 0.35, 0.35, 0.20])
      |> Grid.columns([1.0 / 3.0, 1.0 / 3.0, 1.0 / 3.0])
      |> Grid.row_gap(0)
      |> Grid.column_gap(0)
      |> Grid.define_areas(%{
        banner: {0, 0, 1, 3},
        footer: {3, 0, 1, 3},
        tile1: {1, 0, 1, 1},
        tile2: {1, 1, 1, 1},
        tile3: {1, 2, 1, 1},
        tile4: {2, 0, 1, 1},
        tile5: {2, 1, 1, 1},
        tile6: {2, 2, 1, 1}
      })

    # Calculate the frames
    cell_frames = Grid.calculate(grid)

    # Retrieve frames for banner and footer
    banner_frame = Grid.area_frame(grid, cell_frames, :banner)
    footer_frame = Grid.area_frame(grid, cell_frames, :footer)
    t3 = Grid.area_frame(grid, cell_frames, :tile3)

    # Build the graph
    graph =
      Scenic.Graph.build()
      |> Scenic.Primitives.group(fn graph ->
        graph
        |> Flamelex.GUI.Utils.Draw.background(frame, :orange)
        |> render_title(banner_frame, %{})
        |> render_agent_card(t3, %{})
        |> render_tools(footer_frame)
      end)

    # Conditionally render the new agent modal
    if new_agent_mode? do
      maybe_render_new_agent_modal(graph, frame, state)
    else
      graph
    end
  end

  def render_title(graph, %Widgex.Frame{} = f, _args) do
    graph
    |> Scenic.Primitives.rectangle(f.size.box, fill: :green, t: f.pin.point)
    |> ScenicWidgets.Markup.Header1.draw(%{
      frame: f,
      text: "High Council",
      color: :white
    })
  end

  def render_agent_card(graph, %Widgex.Frame{} = f, _args) do
    graph
    |> Scenic.Primitives.rectangle(f.size.box, fill: :blue, t: f.pin.point)
    |> ScenicWidgets.Markup.Header1.draw(%{
      frame: f,
      text: "Agent: Maxwell",
      color: :white
    })
  end

  def render_tools(graph, %Widgex.Frame{} = f) do
    graph
    |> Flamelex.GUI.Utils.Draw.background(f, :grey)
    |> Scenic.Components.button("New agent",
      id: :new_agent,
      translate: Widgex.Frame.center(f).point
    )
  end

  def maybe_render_new_agent_modal(graph, %Frame{} = frame, %State{} = state) do
    # Create a new grid for the modal, which will be the middle third and 80% height
    modal_grid =
      Grid.new(frame)
      # 85% height in the middle
      # Adjust to make the modal slightly larger (85% height)
      |> Grid.rows([0.075, 0.85, 0.075])
      # Modal in the middle third, slightly wider (e.g., 66% of the width)
      # Adjust to make the modal wider
      |> Grid.columns([0.17, 0.66, 0.17])
      |> Grid.define_areas(%{
        # Centered modal
        modal: {1, 1, 1, 1}
      })

    # Calculate the frames for the modal
    modal_frames = Grid.calculate(modal_grid)
    modal_frame = Grid.area_frame(modal_grid, modal_frames, :modal)

    # Render the modal and overlay
    graph
    |> Scenic.Primitives.group(fn graph ->
      graph
      # Draw a semi-transparent overlay to grey out the background
      |> Scenic.Primitives.rectangle(frame.size.box,
        # Semi-transparent grey to see background
        # fill: {:color, :black, 128},
        fill: {:color_rgba, {0, 0, 0, 172}},
        t: frame.pin.point
      )

      # Draw the modal itself
      |> render_modal_box(modal_frame, state)
    end)
  end

  defp render_modal_box(graph, %Widgex.Frame{} = f, _state) do
    # Define a new grid to split the modal into a title, body, and buttons at the bottom
    modal_grid =
      Grid.new(f)
      # Title (20%), Body (60%), Buttons (20%)
      |> Grid.rows([0.2, 0.6, 0.2])
      # Single column
      |> Grid.columns([1.0])
      |> Grid.define_areas(%{
        title: {0, 0, 1, 1},
        body: {1, 0, 1, 1},
        buttons: {2, 0, 1, 1}
      })

    # Calculate the frames based on the grid layout
    modal_frames = Grid.calculate(modal_grid)
    title_frame = Grid.area_frame(modal_grid, modal_frames, :title)
    body_frame = Grid.area_frame(modal_grid, modal_frames, :body)
    buttons_frame = Grid.area_frame(modal_grid, modal_frames, :buttons)

    # Use rrect to create a rounded rectangle for the modal
    graph
    |> Scenic.Primitives.rrect({f.size.width, f.size.height, 20},
      fill: :white,
      t: {f.pin.x, f.pin.y - 15}
    )

    # Title section
    |> Scenic.Primitives.text("Enter new agent details:",
      font_size: 20,
      fill: :black,
      translate: {title_frame.pin.x + 20, title_frame.pin.y + 20}
    )

    # Body section (this is where input fields can be added later)
    |> Scenic.Primitives.text("Agent details go here:",
      font_size: 18,
      fill: :grey,
      translate: {body_frame.pin.x + 20, body_frame.pin.y + 20}
    )

    # Buttons section (with two buttons)
    |> Scenic.Components.button("Cancel",
      id: :cancel_modal,
      translate: {buttons_frame.pin.x + 20, buttons_frame.pin.y + 20}
    )
    |> Scenic.Components.button("Save",
      id: :save_agent,
      # Offset the second button
      translate: {buttons_frame.pin.x + 120, buttons_frame.pin.y + 20}
    )
  end

  # Example of adding input fields or buttons inside the modal
  # defp render_input_fields(graph, modal_frame) do
  #   graph
  #   |> Scenic.Primitives.text("Name:",
  #     font_size: 18,
  #     translate: {modal_frame.pin.x + 20, modal_frame.pin.y + 80}
  #   )
  #   |> Scenic.Components.input_text("Enter name",
  #     id: :agent_name,
  #     translate: {modal_frame.pin.x + 20, modal_frame.pin.y + 100}
  #   )
  #   |> Scenic.Primitives.text("Role:",
  #     font_size: 18,
  #     translate: {modal_frame.pin.x + 20, modal_frame.pin.y + 140}
  #   )
  #   |> Scenic.Components.input_text("Enter role",
  #     id: :agent_role,
  #     translate: {modal_frame.pin.x + 20, modal_frame.pin.y + 160}
  #   )

  #   # Add Submit button
  #   |> Scenic.Components.button("Submit",
  #     id: :submit_agent,
  #     translate: {modal_frame.pin.x + 20, modal_frame.pin.y + 220}
  #   )

  #   # Add Cancel button
  #   |> Scenic.Components.button("Cancel",
  #     id: :cancel_modal,
  #     translate: {modal_frame.pin.x + 100, modal_frame.pin.y + 220}
  #   )
  # end
end
