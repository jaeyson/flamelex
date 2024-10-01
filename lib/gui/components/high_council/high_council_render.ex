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
      # 80% height in the middle
      |> Grid.rows([0.10, 0.80, 0.10])
      # Modal in the middle third
      |> Grid.columns([1.0 / 3.0, 1.0 / 3.0, 1.0 / 3.0])
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
        # fill: {:color, :grey, 128},
        fill: :grey,
        t: frame.pin.point
      )

      # Draw the modal itself
      |> render_modal_box(modal_frame, state)
    end)
  end

  defp render_modal_box(graph, %Widgex.Frame{} = f, _state) do
    # modal_frame = %{
    #   # Modal position based on the calculated grid area
    #   pin: {f.pin.x, f.pin.y},
    #   # Modal size calculated based on 80% height and middle third width
    #   size: f.size
    # }

    graph
    |> Scenic.Primitives.rectangle(f.size.box, fill: :white, t: f.pin.point)
    |> Scenic.Primitives.text("Enter new agent details:",
      font_size: 20,
      translate: {f.pin.x + 20, f.pin.y + 40}
    )

    # Add more input fields (NeoTextField or other components) here
  end
end
