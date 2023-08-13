defmodule Flamelex.GUI.Component.Renseijin.Utils do
  alias Widgex.Structs.Frame
  alias Flamelex.GUI.Component.Renseijin.State

  def draw_circles(%Scenic.Graph{} = graph, %Frame{} = frame, %State{} = state) do
    graph
    |> draw_circle(frame, state, :one)
    |> draw_circle(frame, state, :two)
    |> draw_circle(frame, state, :three)
  end

  def draw_circle(%Scenic.Graph{} = graph, %Frame{} = frame, %State{} = state, :one) do
    graph
    |> Scenic.Primitives.circle(
      State.circle_rad(frame),
      stroke: {
        state.primary_stroke,
        state.primary_color
      }
    )
  end

  def draw_circle(%Scenic.Graph{} = graph, %Frame{} = frame, %State{} = state, :two) do
    graph
    |> Scenic.Primitives.circle(
      State.inner_circle_radius(frame, state),
      stroke: {
        state.primary_stroke,
        state.primary_color
      }
    )
  end

  def draw_circle(
        %Scenic.Graph{} = graph,
        %Frame{} = frame,
        %State{gap_size: gap_size} = state,
        :three
      ) do
    graph
    |> Scenic.Primitives.circle(
      State.inner_circle_radius(frame, state) + 1.5 * gap_size,
      stroke: {
        state.primary_stroke,
        state.primary_color
      }
    )
  end

  defp within_box?({query_x, query_y}, %{x: base_x, y: base_y}, radius) do
    low_x = base_x - radius
    low_y = base_y - radius
    high_x = base_x + radius
    high_y = base_y + radius

    low_x <= query_x and query_x <= high_x and low_y <= query_y and query_y <= high_y
  end

  defp degree_in_radians(x) do
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

# def draw_triangles(graph, args) do
#   %{
#     radius: radius,
#     center: center,
#     outer_rim: rim,
#     gap_size: size,
#     rotation: r
#   } = args

#   graph
#   |> Scenic.Primitives.triangle(
#     equilateral_triangle_coords(radius),
#     id: :inner_triangle,
#     stroke: {1, @primary_color}
#   )
#   |> Scenic.Primitives.triangle(
#     equilateral_triangle_coords(radius - rim + size),
#     id: :mid_triangle,
#     stroke: {1, @primary_color},
#     rotate: r
#   )
#   |> Scenic.Primitives.triangle(
#     equilateral_triangle_coords(radius - rim + 2.5 * size),
#     id: :outer_triangle,
#     stroke: {1, @primary_color}
#   )
# end

# def draw_taijitu(graph, frame, args) do
#   radius = inner_circle_radius(args)
#   # TODO just having this grow & shrink would be AWESOME!!!
#   # radius = inner_circle_radius(args)/2

#   color = :yellow

#   # circle_rad = circle_rad(frame)

#   # TODO add tails

#   graph
#   # |> Scenic.Primitives.line({{0, -radius}, {0, radius}}, stroke: {1, :grey})
#   # |> Scenic.Primitives.line({{-5, 0}, {5, 0}}, stroke: {1, :grey})
#   # |> Scenic.Primitives.line({{-5, 0}, {5, 0}}, stroke: {1, :grey}, translate: {0, -radius/2})
#   # |> Scenic.Primitives.line({{-5, 0}, {5, 0}}, stroke: {1, :grey}, translate: {0, radius/2})
#   |> Scenic.Primitives.group(
#     fn graph ->
#       graph
#       |> Scenic.Primitives.circle(radius / 6, stroke: {1, color}, translate: {0, -radius / 2})
#       |> Scenic.Primitives.circle(radius / 6, stroke: {1, color}, translate: {0, radius / 2})
#       |> Scenic.Primitives.arc({radius / 2, @pi},
#         stroke: {1, color},
#         rotate: 3 * @pi / 2,
#         translate: {0, -radius / 2}
#       )
#       |> Scenic.Primitives.arc({radius / 2, @pi},
#         stroke: {1, color},
#         rotate: @pi / 2,
#         translate: {0, radius / 2}
#       )
#       |> Scenic.Primitives.circle(radius, stroke: {1, color})
#       |> add_taijitu_tails(radius)
#     end,
#     id: :taijitu,
#     rotate: args.rotation
#   )
# end

# def add_taijitu_tails(graph, inner_radius) do
#   width_factor = 3
#   finish_height = 2 * inner_radius

#   graph
#   |> Scenic.Primitives.path(
#     [
#       :begin,
#       {:move_to, 0, inner_radius},
#       {:bezier_to, 0.67 * inner_radius * width_factor, inner_radius,
#        (1 - 0.67) * inner_radius * width_factor, finish_height, inner_radius * width_factor,
#        finish_height}
#       # {:line_to, 300, 600},
#       # :close_path
#     ],
#     #  fill: :white,
#     # stroke_fill: :yellow,
#     # stroke_width: 2
#     stroke: {1, :yellow}
#   )
#   |> Scenic.Primitives.path(
#     [
#       :begin,
#       {:move_to, 0, -inner_radius},
#       {:bezier_to, -1 * 0.67 * inner_radius * width_factor, -1 * inner_radius,
#        -1 * (1 - 0.67) * inner_radius * width_factor, -1 * finish_height,
#        -1 * inner_radius * width_factor, -1 * finish_height}
#       # {:line_to, 300, 600},
#       # :close_path
#     ],
#     #  fill: :white,
#     # stroke_fill: :yellow,
#     # stroke_width: 2
#     stroke: {1, :yellow}
#   )
# end

# TODO this pattern was interesting... explore it later
# def add_taijitu_tails(graph, width) do
#    graph
#    |> Scenic.Primitives.path( [
#       :begin,
#       {:move_to, 0, width},
#       {:bezier_to, 0, 0, 0, 0, width, 0}
#       # {:line_to, 300, 600},
#       # :close_path
#     ],
#    #  fill: :white,
#    # stroke_fill: :yellow,
#    # stroke_width: 2
#    stroke: {1, :yellow}
#   )
# end

# def draw_outer_square(graph, args) do
#   l = inner_circle_radius(args)

#   graph
#   |> Scenic.Primitives.quad(
#     {{-l, -l}, {-l, l}, {l, -l}, {l, l}},
#     stroke: {1, :grey}
#   )
#   |> Scenic.Primitives.quad(
#     {{l, l}, {-l, l}, {-l, -l}, {l, -l}},
#     stroke: {1, :grey}
#   )

#   # |> render_pyramids()
# end

# def render_pyramids(graph) do
#   graph
#   |> Scenic.Primitives.triangle(
#     right_triangle_coords(),
#     id: {:top_left, :left},
#     stroke: {1, :white},
#     fill: :dark_gray
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

# def equilateral_triangle_coords(radius) do
#   {
#     {-1 * :math.sqrt(3) * radius / 2, radius / 2},
#     {0, -1 * radius},
#     {:math.sqrt(3) * radius / 2, radius / 2}
#   }
# end

# def right_triangle_coords do
#   size = 100

#   {
#     # top-right vertex
#     {size, size},
#     # top-left vertex
#     {0, size},
#     # bottom vertex
#     {0, 0}
#   }
# end
