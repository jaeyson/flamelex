defmodule Flamelex.GUI.Components.Renseijin.Rend do
  @doc """
  The unique function which renders the Renseijin component.
  """

  alias Flamelex.GUI.Components.Renseijin

  # a constant for π (change for potentially wacky behaviour~~)
  @pi 3.14159265359

  # it's called `er` because the module is Rend,
  # to together it's Rend.er
  @spec er(Widgex.Frame.t(), Renseijin.State.t()) :: Scenic.Graph.t()
  def er(%Widgex.Frame{} = frame, %Renseijin.State{} = state) do
    Scenic.Graph.build()
    |> Renseijin.Utils.draw_background(frame, state)
    |> Scenic.Primitives.group(
      fn graph ->
        graph
        |> Renseijin.Utils.draw_circles(frame, state)
        |> Renseijin.Utils.draw_triangles(frame, state)
        |> draw_taijitu(frame, state)
        |> draw_hexagons(frame, state)

        # |> draw_symbols(frame, state)

        # |> Utils.draw_squares(frame, state)
        # |> Utils.draw_pyramids(frame, state)
      end,
      id: __MODULE__,
      translate: Widgex.Frame.center(frame).point
    )
    |> Scenic.Graph.modify(:scissor, frame.size.box)
  end

  #############################################################################
  # Draw Hexagon
  # ===========================================================================

  # some AI magix, don't touch
  @magic_coefficient 2 / 3 * (3 / 4) * (2 / 3)
  def draw_hexagons(%Scenic.Graph{} = graph, %Widgex.Frame{} = frame, %Renseijin.State{} = state) do
    radius = Renseijin.State.inner_radius(frame, state)

    graph
    |> draw_hexagon(state, radius: radius / 2)
    |> draw_little_hexagons(frame, state)
    |> draw_little_hexagons(frame, state, 1)
    |> draw_little_hexagons(frame, state, 2)

    # |> draw_little_hexagon(state, radius: radius / 2)
    # |> draw_little_hexagon(state, radius: radius / 4)
    # |> draw_little_hexagon(state, radius: radius / 8)

    # |> draw_hexagon(state, radius: radius * @magic_coefficient)
  end

  def draw_little_hexagons(graph, frame, state, n \\ 0) do
    radius = Renseijin.State.inner_radius(frame, state)

    graph
    |> Scenic.Primitives.group(
      fn graph ->
        graph
        |> draw_little_hexagon(state, radius: radius / 2)
        |> draw_little_hexagon(state, radius: radius / 4)
        |> draw_little_hexagon(state, radius: radius / 8)
        |> draw_little_hexagon(state, radius: radius / 16)
      end,
      rotate: n * @pi / 3
    )

    # I think the effect is kind of lost after 4
    # |> draw_little_hexagon(state, radius: radius / 32)
  end

  def draw_hexagon(%Scenic.Graph{} = graph, %Renseijin.State{} = state, radius: radius) do
    hexagon_path_elements = hexagon_path_elements(radius)

    graph
    |> Scenic.Primitives.path(
      hexagon_path_elements,
      stroke: state.relief_stroke,
      cap: :round
    )
  end

  def draw_little_hexagon(%Scenic.Graph{} = graph, %Renseijin.State{} = state, radius: radius) do
    hexagon_path_elements = hexagon_path_elements(radius / 2)

    graph
    |> Scenic.Primitives.path(
      hexagon_path_elements,
      stroke: state.relief_stroke,
      cap: :round,
      translate: {0, -radius}
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
  # Taijitsu
  # ===========================================================================

  def draw_taijitu(%Scenic.Graph{} = graph, %Widgex.Frame{} = frame, %Renseijin.State{} = state) do
    radius = Renseijin.State.inner_radius(frame, state)
    # dot_radii = radius / 2

    graph
    # |> Scenic.Primitives.line({{0, -dot_radii}, {0, dot_radii}}, stroke: {1, :grey})
    |> draw_taijitu_group(frame, state, radius)
    |> add_taijitu_tails(state, radius)
  end

  def draw_taijitu_group(graph, frame, state, radius) do
    {stroke_w, _yellow} = state.taijitu.stroke

    stroke_color = Enum.at(state.taijitu.rainbow, state.taijitu.color_index)

    graph
    |> Scenic.Primitives.group(
      fn graph ->
        graph
        |> Scenic.Primitives.group(
          fn graph ->
            graph
            |> Scenic.Primitives.circle(radius / 6,
              stroke: {stroke_w, stroke_color},
              id: :taijitu_tail
            )
            # TODO reposition & rotate this lol
            |> Scenic.Primitives.text(
              # this symbol is lowercase "lambda" in greek script
              "λ",
              # "M",
              font_size: 36,
              font: :noto_sans,
              fill: stroke_color,
              text_align: :center,
              # translate: {36 / 2, 0},
              translate: {2, 12},
              id: :taijitu_text
            )
          end,
          rotate: -1 * degree_in_radians(state.rotation),
          translate: {0, -radius / 2}
        )
        |> Scenic.Primitives.group(
          fn graph ->
            graph
            |> Scenic.Primitives.circle(radius / 6,
              stroke: {stroke_w, stroke_color},
              id: :taijitu_tail
            )
            |> Scenic.Primitives.text(
              # this symbol is the "eye of horus" in merotic script, not a rectangle
              "𐦝",
              font_size: 38,
              font: :meroitic,
              fill: stroke_color,
              text_align: :center,
              translate: {0, 12},
              # rotate: -1 * degree_in_radians(state.rotation),
              id: :taijitu_text
            )
          end,
          rotate: -1 * degree_in_radians(state.rotation),
          translate: {0, radius / 2}
        )
        |> Scenic.Primitives.arc({radius / 2, @pi},
          stroke: {stroke_w, stroke_color},
          rotate: 3 * @pi / 2,
          translate: {0, -radius / 2},
          id: :taijitu_tail
        )
        |> Scenic.Primitives.arc({radius / 2, @pi},
          stroke: {stroke_w, stroke_color},
          rotate: @pi / 2,
          translate: {0, radius / 2},
          id: :taijitu_tail
        )
        |> Scenic.Primitives.circle(radius, stroke: {stroke_w, stroke_color}, id: :taijitu_tail)
      end,
      id: :taijitu,
      rotate: degree_in_radians(state.rotation)
    )
  end

  # TODO this should all get cleaned up...
  def add_taijitu_tails(graph, state, inner_radius) do
    width_factor = 6.12
    finish_height = 3 * inner_radius

    stroke_color = Enum.at(state.taijitu.rainbow, state.taijitu.color_index)

    # same id for both paths, so they can be updated together
    graph
    |> Scenic.Primitives.path(
      [
        :begin,
        {:move_to, 0, inner_radius},
        {:bezier_to, 0.67 * inner_radius * width_factor, inner_radius,
         (1 - 0.67) * inner_radius * width_factor, finish_height, inner_radius * width_factor,
         finish_height}
      ],
      stroke: {state.taijitu.stroke_width, stroke_color},
      id: :taijitu_tail
    )
    |> Scenic.Primitives.path(
      [
        :begin,
        {:move_to, 0, -inner_radius},
        {:bezier_to, -1 * 0.67 * inner_radius * width_factor, -1 * inner_radius,
         -1 * (1 - 0.67) * inner_radius * width_factor, -1 * finish_height,
         -1 * inner_radius * width_factor, -1 * finish_height}
      ],
      stroke: {state.taijitu.stroke_width, stroke_color},
      id: :taijitu_tail
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

  # defp draw_symbols(graph, %Widgex.Frame{} = frame, %Renseijin.State{} = state) do
  #   graph
  #   |> Scenic.Primitives.text(
  #     # this symbol is the "eye of horus" in merotic script, not a rectangle
  #     "𐦝",
  #     font_size: 40,
  #     font: :meroitic,
  #     fill: :black
  #     # id: :taijitu_tail
  #   )
  #   |> Scenic.Primitives.text(
  #     # this symbol is lowercase "lambda" in greek script
  #     "λ",
  #     font_size: 36,
  #     font: :noto_sans,
  #     fill: :black,
  #     translate: {0, 50}
  #     # id: :taijitu_tail
  #   )
  # end

  def eye_width() do
    {:ok, meroitic_font_metrics} =
      TruetypeMetrics.load("./assets/fonts/Noto_Sans_Meroitic/NotoSansMeroitic-Regular.ttf")

    FontMetrics.width("𐦝", 40, meroitic_font_metrics)
  end

  def lambda_width() do
    {:ok, noto_sans_font_metrics} =
      TruetypeMetrics.load("./assets/fonts/Noto_Sans/static/NotoSans-Regular.ttf")

    FontMetrics.width("λ", 36, noto_sans_font_metrics)
  end

  def degree_in_radians(x) do
    2 * @pi * x / 360
  end
end
