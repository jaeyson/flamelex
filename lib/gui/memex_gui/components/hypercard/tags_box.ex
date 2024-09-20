defmodule Memelex.GUI.Components.HyperCard.TagsBox do
  use Scenic.Component

  alias Scenic.Graph
  import Scenic.Primitives

  @default_font_size 16
  @default_padding 10
  @default_bg_color :light_gray

  # Options:
  # tags: list of strings (the tags to render)
  # x, y: starting coordinates for rendering the tags
  # font_size: optional, size of the font used for rendering
  # padding: optional, padding between tags
  # def draw(%{tags: tags, x: x, y: y, font_size: font_size, padding: padding}) do
  #   font_size = font_size || @default_font_size
  #   padding = padding || @default_padding

  #   graph = build_graph(tags, x, y, font_size, padding)

  #   {:ok, %{graph: graph}}
  # end

  def draw(%Scenic.Graph{} = graph, tags) when is_list(tags) do
    font_size = @default_font_size
    padding = @default_padding

    Enum.reduce(tags, graph, fn tag, graph ->
      graph
      # |> text(tag, fill: :black, font_size: font_size, translate: {x, y})
      |> rect({String.length(tag) * font_size / 2, font_size + padding},
        fill: @default_bg_color,
        stroke: {1, :black}
        # translate: {x - padding / 2, y - padding / 2}
      )
      |> text(tag, fill: :black, font_size: font_size, translate: {0, font_size})

      # |> translate({x, y + font_size + padding})
    end)
  end

  # def filter_event(event, _, state), do: {:noreply, state}
end
