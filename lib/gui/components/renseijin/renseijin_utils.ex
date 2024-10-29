defmodule Flamelex.GUI.Components.Renseijin.Utils do
  alias Widgex.Frame
  alias Flamelex.GUI.Components.Renseijin
  alias Flamelex.GUI.Components.Renseijin.State

  # a constant for π (change for potentially wacky behaviour~~)
  @pi 3.14159265359

  #############################################################################
  # Drawing circles
  # ===========================================================================

  def draw_circles(%Scenic.Graph{} = graph, %Frame{} = frame, %Renseijin.State{} = state) do
    graph
    |> draw_circle(state, Renseijin.State.radius(frame))
    |> draw_circle(state, Renseijin.State.inner_radius(frame, state))
    |> draw_circle(state, Renseijin.State.outer_radius(frame, state))
  end

  def draw_circle(
        %Scenic.Graph{} = graph,
        %Renseijin.State{} = state,
        radius
      )
      when is_float(radius) do
    graph
    |> Scenic.Primitives.circle(
      radius,
      stroke: {
        state.primary_stroke,
        state.primary_color
      }
    )
  end

  #############################################################################
  # Drawing triangles
  # ===========================================================================

  def draw_triangles(%Scenic.Graph{} = graph, %Frame{} = frame, %Renseijin.State{} = state) do
    graph
    |> draw_triangle(state, equilateral: Renseijin.State.radius(frame))
    |> draw_triangle(state, equilateral: Renseijin.State.inner_radius(frame, state))
    |> draw_triangle(state, equilateral: Renseijin.State.outer_radius(frame, state))
  end

  def draw_triangle(
        %Scenic.Graph{} = graph,
        %Renseijin.State{} = state,
        equilateral: radius
      )
      when is_float(radius) do
    graph
    |> Scenic.Primitives.triangle(
      equilateral_triangle_coords(radius),
      stroke: {
        state.primary_stroke,
        # {:color_rgba, {r, g, b, a}}
        state.primary_color
      }
    )
  end

  # creates an "upwards pointing" equilateral triangle
  # the `radius` is the distance from the center of the triangle to any of its vertices
  def equilateral_triangle_coords(radius) do
    {
      {-1 * :math.sqrt(3) * radius / 2, radius / 2},
      {0, -1 * radius},
      {:math.sqrt(3) * radius / 2, radius / 2}
    }
  end

  #############################################################################
  # Draw Squares
  # ===========================================================================

  def draw_squares(%Scenic.Graph{} = graph, %Frame{} = frame, %Renseijin.State{} = state) do
    graph
    |> draw_square(state, Renseijin.State.inner_radius(frame, state))
  end

  def draw_square(
        %Scenic.Graph{} = graph,
        %Renseijin.State{} = state,
        radius
      ) do
    # note - the `radius` of the square is the centroid to the flat-edge, NOT the vertex
    graph
    |> Scenic.Primitives.quad(
      square_coords(radius),
      # TODO use secondary color, or get themes working properly ;)
      stroke: {1, :grey}
    )
  end

  def square_coords(radius) do
    r = radius

    {
      {-r, r},
      {-r, -r},
      {r, -r},
      {r, r}
    }
  end

  #############################################################################
  # Draw Pyramids
  # ===========================================================================

  def draw_pyramids(%Scenic.Graph{} = graph, %Frame{} = frame, %Renseijin.State{} = state) do
    radius = Renseijin.State.inner_radius(frame, state) * (2 / 3) * (3 / 4) * (2 / 3)
    dot_radii = radius / 2

    graph
    |> draw_triangle(state, right_angle: radius + dot_radii / 3)
  end

  def draw_triangle(
        %Scenic.Graph{} = graph,
        %Renseijin.State{} = state,
        right_angle: length
      )
      when is_float(length) do
    graph
    |> Scenic.Primitives.triangle(
      right_triangle_coords(length),
      stroke: {
        state.primary_stroke,
        state.primary_color
      }
    )
  end

  def right_triangle_coords(length) do
    {
      {length, length},
      {0, length},
      {0, 0}
    }
  end

  #############################################################################
  # Draw Background
  # ===========================================================================

  @background_images [
    # "images/jupiter.jpg",
    # "images/milky_way.jpg",
    "images/ngc_4535.jpg",
    # "images/pexels_sunrise.jpg",
    # "images/uluru_sunrise.jpg"
    # "images/uluru-northern-territory-australia-139.jpg"
    "images/burning_man_2016_temple_friday_sunrise.jpeg"
  ]

  def draw_background(
        %Scenic.Graph{} = graph,
        %Widgex.Frame{} = frame,
        %Renseijin.State{} = state
      ) do
    graph
    |> Scenic.Primitives.rect(frame.size.box,
      # translate: Coordinates.point(frame.pin),
      translate: frame.pin.point,
      # fill: {:image, "images/burning_man_2016_temple_friday_sunrise.jpeg"}
      fill: {:image, Enum.random(@background_images)}
    )
    |> draw_mask_with_gradient(frame, state)

    # |> Scenic.Primitives.rect({100, 50},
    #   fill: {:linear, {50, 25, 10, 45, :blue, :yellow}},
    #   translate: frame.pin.point
    # )
  end

  # def draw_mask(graph, frame, state) do
  #   graph
  #   |> Scenic.Primitives.circle(
  #     State.outer_radius(frame, state),
  #     fill: :black,
  #     translate: Frame.center(frame).point
  #   )
  # end

  # @inner_color :white
  # @inner_color {:color_rgba, {255, 255, 255, 172}}
  @inner_color {:color_rgba, {250, 250, 210, 172}}
  @fade_out 500
  @fully_transparent {0, 0, 0, 0}
  def draw_mask_with_gradient(graph, frame, state) do
    # Get the center of the frame and radius
    center_point = Widgex.Frame.center(frame).point
    {center_x, center_y} = center_point
    inner_radius = Renseijin.State.inner_radius(frame, state)
    outer_radius = Renseijin.State.outer_radius(frame, state)

    # stroke_color = Enum.at(state.taijitu.rainbow, state.taijitu.color_index)

    # Define a radial gradient with proper parameters
    # gradient = {:radial, {0, 0, outer_radius, outer_radius + @fade_out, :white, :black}}
    gradient = {:radial, {0, 0, inner_radius / 3, outer_radius, @inner_color, @fully_transparent}}

    # Apply the radial gradient to the circle primitive
    graph
    |> Scenic.Primitives.circle(
      outer_radius + @fade_out,
      # outer_radius,
      # Apply the radial gradient
      fill: gradient,
      translate: center_point
      # id: :taijitu_tail
    )
  end

  #############################################################################
  # Other Stuff
  # ===========================================================================

  def within_box?({query_x, query_y}, %{x: base_x, y: base_y}, radius) do
    low_x = base_x - radius
    low_y = base_y - radius
    high_x = base_x + radius
    high_y = base_y + radius

    low_x <= query_x and query_x <= high_x and low_y <= query_y and query_y <= high_y
  end

  def degree_in_radians(x) do
    2 * @pi * x / 360
  end
end

# new_graph =
#   scene.assigns.graph
#   |> Scenic.Graph.modify(
#     :inner_triangle,
#     &Scenic.Primitives.update_opts(&1, rotate: -1 * degree_in_radians(scene.assigns.rotation))
#   )
#   |> reset_mid_triangle(scene)
#   |> Scenic.Graph.modify(
#     :outer_triangle,
#     &Scenic.Primitives.update_opts(&1, rotate: -1 * degree_in_radians(scene.assigns.rotation))
#   )
#   |> Scenic.Graph.modify(
#     :taijitu,
#     &Scenic.Primitives.update_opts(&1, rotate: degree_in_radians(scene.assigns.rotation))
#   )

# def reset_mid_triangle(graph, scene) do
#   color = Scenic.Color.named(:red)

#   graph
#   |> Scenic.Graph.modify(
#     :mid_triangle,
#     &Scenic.Primitives.update_opts(&1,
#       color: color,
#       rotate: degree_in_radians(scene.assigns.rotation)
#     )
#   )
# end

# def do_animate(graph, rotation) do
#   graph
#   |> Scenic.Graph.modify(
#     :inner_triangle,
#     &Scenic.Primitives.update_opts(&1, rotate: degree_in_radians(rotation))
#   )
#   |> animate_mid_triangle(rotation)
#   |> Scenic.Graph.modify(
#     :outer_triangle,
#     &Scenic.Primitives.update_opts(&1, rotate: 2 * degree_in_radians(rotation))
#   )
#   |> Scenic.Graph.modify(
#     :taijitu,
#     &Scenic.Primitives.update_opts(&1, rotate: degree_in_radians(rotation))
#   )
# end

# def animate_mid_triangle(graph, rotation) do
#   graph
#   |> Scenic.Graph.modify(
#     :mid_triangle,
#     &Scenic.Primitives.update_opts(&1,
#       stroke: {1, :green},
#       rotate: -1 * degree_in_radians(rotation)
#     )
#   )
# end
