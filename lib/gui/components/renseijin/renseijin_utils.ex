defmodule Flamelex.GUI.Component.Renseijin.Utils do
  alias Widgex.Structs.{Frame, Coordinates, Dimensions}
  alias Flamelex.GUI.Component.Renseijin.State

  # a constant for π (change for potentially wacky behaviour~~)
  @pi 3.14159265359

  #############################################################################
  # Drawing circles
  # ===========================================================================

  def draw_circles(%Scenic.Graph{} = graph, %Frame{} = frame, %State{} = state) do
    graph
    |> draw_circle(state, State.radius(frame))
    |> draw_circle(state, State.inner_radius(frame, state))
    |> draw_circle(state, State.outer_radius(frame, state))
  end

  def draw_circle(
        %Scenic.Graph{} = graph,
        %State{} = state,
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

  def draw_triangles(%Scenic.Graph{} = graph, %Frame{} = frame, %State{} = state) do
    graph
    |> draw_triangle(state, equilateral: State.radius(frame))
    |> draw_triangle(state, equilateral: State.inner_radius(frame, state))
    |> draw_triangle(state, equilateral: State.outer_radius(frame, state))
  end

  def draw_triangle(
        %Scenic.Graph{} = graph,
        %State{} = state,
        equilateral: radius
      )
      when is_float(radius) do
    graph
    |> Scenic.Primitives.triangle(
      equilateral_triangle_coords(radius),
      stroke: {
        state.primary_stroke,
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

  def draw_squares(%Scenic.Graph{} = graph, %Frame{} = frame, %State{} = state) do
    graph
    |> draw_square(state, State.inner_radius(frame, state))
  end

  def draw_square(
        %Scenic.Graph{} = graph,
        %State{} = state,
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
  # Taijitsu
  # ===========================================================================

  def draw_taijitu(%Scenic.Graph{} = graph, %Frame{} = frame, %State{} = state) do
    radius = State.inner_radius(frame, state)
    # dot_radii = radius / 2

    graph
    # |> Scenic.Primitives.line({{0, -dot_radii}, {0, dot_radii}}, stroke: {1, :grey})
    |> draw_taijitu_group(frame, state, radius)
    |> add_taijitu_tails(state, radius)
  end

  def draw_taijitu_group(graph, frame, state, radius) do
    stroke = state.taijitu.stroke

    graph
    |> Scenic.Primitives.group(
      fn graph ->
        graph
        |> Scenic.Primitives.circle(radius / 6, stroke: stroke, translate: {0, -radius / 2})
        |> Scenic.Primitives.circle(radius / 6, stroke: stroke, translate: {0, radius / 2})
        |> Scenic.Primitives.arc({radius / 2, @pi},
          stroke: stroke,
          rotate: 3 * @pi / 2,
          translate: {0, -radius / 2}
        )
        |> Scenic.Primitives.arc({radius / 2, @pi},
          stroke: stroke,
          rotate: @pi / 2,
          translate: {0, radius / 2}
        )
        |> Scenic.Primitives.circle(radius, stroke: stroke)
      end,
      id: :taijitu,
      rotate: degree_in_radians(state.rotation)
    )
  end

  # TODO this should all get cleaned up...
  def add_taijitu_tails(graph, state, inner_radius) do
    width_factor = 6.12
    finish_height = 3 * inner_radius

    graph
    |> Scenic.Primitives.path(
      [
        :begin,
        {:move_to, 0, inner_radius},
        {:bezier_to, 0.67 * inner_radius * width_factor, inner_radius,
         (1 - 0.67) * inner_radius * width_factor, finish_height, inner_radius * width_factor,
         finish_height}
      ],
      stroke: state.taijitu.stroke
    )
    |> Scenic.Primitives.path(
      [
        :begin,
        {:move_to, 0, -inner_radius},
        {:bezier_to, -1 * 0.67 * inner_radius * width_factor, -1 * inner_radius,
         -1 * (1 - 0.67) * inner_radius * width_factor, -1 * finish_height,
         -1 * inner_radius * width_factor, -1 * finish_height}
      ],
      stroke: state.taijitu.stroke
    )
  end

  # TODO this pattern was interesting... explore it later
  # def add_taijitu_tails(graph, width) do
  #   graph
  #   |> Scenic.Primitives.path(
  #     [
  #       :begin,
  #       {:move_to, 0, width},
  #       {:bezier_to, 0, 0, 0, 0, width, 0}
  #       # {:line_to, 300, 600},
  #       # :close_path
  #     ],
  #     #  fill: :white,
  #     # stroke_fill: :yellow,
  #     # stroke_width: 2
  #     stroke: {1, :yellow}
  #   )
  # end

  #############################################################################
  # Draw Pyramids
  # ===========================================================================

  def draw_pyramids(%Scenic.Graph{} = graph, %Frame{} = frame, %State{} = state) do
    radius = State.inner_radius(frame, state) * (2 / 3) * (3 / 4) * (2 / 3)
    dot_radii = radius / 2

    graph
    |> draw_triangle(state, right_angle: radius + dot_radii / 3)
  end

  def draw_triangle(
        %Scenic.Graph{} = graph,
        %State{} = state,
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
  # Draw Hexagon
  # ===========================================================================

  # some AI magix, don't touch
  @magic_coefficient 2 / 3 * (3 / 4) * (2 / 3)
  def draw_hexagons(%Scenic.Graph{} = graph, %Frame{} = frame, %State{} = state) do
    radius = State.inner_radius(frame, state)

    graph
    |> draw_hexagon(state, radius: radius / 2)

    # |> draw_hexagon(state, radius: radius * @magic_coefficient)
  end

  def draw_hexagon(%Scenic.Graph{} = graph, %State{} = state, radius: radius) do
    hexagon_path_elements = hexagon_path_elements(radius)

    graph
    |> Scenic.Primitives.path(
      hexagon_path_elements,
      stroke: state.relief_stroke,
      cap: :round
    )
  end

  def hexagon_path_elements(radius) do
    angle_step = :math.pi() / 3

    path_elements =
      Enum.map(0..5, fn i ->
        angle = i * angle_step
        x = :math.cos(angle) * radius
        y = :math.sin(angle) * radius
        {:line_to, x, y}
      end)

    [{:move_to, :math.cos(0) * radius, :math.sin(0) * radius}] ++ path_elements ++ [:close_path]
  end

  #############################################################################
  # Draw Background
  # ===========================================================================

  def draw_background(%Scenic.Graph{} = graph, %Frame{} = frame, %State{} = state) do
    graph
    |> Scenic.Primitives.rect(Dimensions.box(frame.size),
      translate: Coordinates.point(frame.pin),
      fill: {:image, "images/ngc_4535.jpg"}
    )
    |> draw_mask(frame, state)
  end

  def draw_mask(graph, frame, state) do
    graph
    |> Scenic.Primitives.circle(
      State.outer_radius(frame, state),
      fill: :black,
      translate: Frame.center_tuple(frame)
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
