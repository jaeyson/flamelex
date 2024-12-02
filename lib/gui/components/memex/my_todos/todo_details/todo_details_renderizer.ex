defmodule Flamelex.GUI.Component.TODOdetails.Renderizer do
  alias Flamelex.GUI.Component.TODOdetails

  def render(frame, state) do
    Scenic.Graph.build()
    |> render(frame, state)
  end

  def render(
    %Scenic.Graph{} = graph,
    %Widgex.Frame{} = f,
    %TODOdetails.State{tidbit: %Memelex.TidBit{} = t} = state
  ) do
    Wormhole.capture(fn ->
      # todo_widgets =
      #   args.state.list
      #   |> Enum.map(fn t ->
      #     {NeoHyperCard, %{tidbit: t}}
      #   end)

      # title_h = 60
      title_h = 0.1 * f.size.height
      panel_h = 420

      draw_raw_tidbit = fn graph, %{frame: f} = args ->
        graph
        |> Scenic.Primitives.text("#{prettify_map(t)}",
          font: :ibm_plex_mono,
          font_size: 24,
          fill: :white,
          translate: {f.pin.x + 20, f.pin.y + 20}
        )
      end

      # tidbit_actions = ["Action 1", "Action 2", "Action 3", "Action 4", "Action 5"]
      tidbit_actions =
        case t.meta do
          [%{"actions" => actions}] ->
            Enum.map(actions, fn
              a when is_binary(a) ->
                a

              %{title: t} ->
                t
            end)

          _otherwise ->
            ["No actions"]
        end

      # NOTE - I automatically assumed moving things around in this `blocks` list would move them in the UI - and that's a normal good assumptioni!
      # actually nothying moved because the frames need to be updated, but it would hgave been cooler if the framework understood what I means when I moved the blocks around

      header_f = Widgex.Frame.new(%{size: {f.size.width, title_h}, pin: {0, 0}})
      first_f = Widgex.Frame.new(%{size: {f.size.width, panel_h}, pin: {0, title_h}})
      second_f = Widgex.Frame.new(%{size: {f.size.width, panel_h}, pin: {0, title_h + panel_h}})

      third_f =
        Widgex.Frame.new(%{size: {f.size.width, panel_h}, pin: {0, title_h + 2 * panel_h}})

      fourth_f_big =
        Widgex.Frame.new(%{size: {f.size.width, 2 * panel_h}, pin: {0, title_h + 3 * panel_h}})

      # extra pin height cause fourth frame is so big
      fifth_f =
        Widgex.Frame.new(%{size: {f.size.width, panel_h}, pin: {0, title_h + 5 * panel_h}})

      blocks = [
        {ScenicWidgets.Markup.Header1, %{frame: header_f, text: t.title}},
        # {draw_data_fn(), %{frame: first_f, tidbit: t}},
        # priority, due/planned date, status, tags, labels, notes, history
        {draw_data_fn(), %{frame: first_f, state: state}},
        {draw_action_list_fn(), %{frame: second_f, actions: tidbit_actions}},
        {draw_hist_fn(), %{frame: third_f, tidbit: t}},
        {draw_raw_tidbit, %{frame: fourth_f_big}},
        {draw_hist_fn(), %{frame: fifth_f, tidbit: t}}
      ]

      graph
      |> Scenic.Primitives.group(
        fn graph ->
          graph
          |> ScenicWidgets.VerticalList.add_to_graph(%{
            id: {TODOdetails, t.uuid},
            frame: f,
            items: blocks,
            scroll: state.scroll
          })
        end,
        translate: f.pin.point
      )
    end)
  end

  def draw_data_fn do
    fn
      graph, %{frame: f, state: %{tidbit: t, edit_description?: false}} = args ->
        # IO.puts("ARE WE ALWAYS HERE???")

        graph
        |> draw_neo_card_background(f)
        |> Memelex.GUI.Components.IconButton.add_to_graph(
          %{
            frame: Widgex.Frame.new(pin: {10, 10}, size: {50, 50}),
            icon: "ionicons/black_32/edit.png"
          },
          id: {:edit, t.uuid},
          # need to move it back twice the width because we're right aligning now
          translate: {f.size.width - 20 - 50 - 50, f.pin.y + 5}
        )
        |> Scenic.Primitives.text(t.data,
          font: :ibm_plex_mono,
          font_size: 24,
          fill: :white,
          translate: {f.pin.x + 20, f.pin.y + 20 + 20 + 60}
        )

      graph, %{frame: f, state: %{tidbit: t, edit_description?: true}} = args ->
        IO.puts("EDITING THE DESC")

        graph
        |> draw_neo_card_background(f)
        |> Memelex.GUI.Components.IconButton.add_to_graph(
          %{
            frame: Widgex.Frame.new(pin: {10, 10}, size: {50, 50}),
            icon: "ionicons/black_32/save.png"
          },
          id: {:save, t.uuid},
          # need to move it back twice the width because we're right aligning now
          translate: {f.size.width - 20 - 50 - 50, f.pin.y + 5}
        )
        # |> Scenic.Primitives.text(t.data,
        #   font: :ibm_plex_mono,
        #   font_size: 24,
        #   fill: :white,
        #   translate: {f.pin.x + 20, f.pin.y + 20 + 20 + 60}
        # )

        # |> Scenic.Component.Input.TextField.add_to_graph(
        #   "Some test text",
        #   id: {:data, t.uuid},
        #   # translate: f.pin.point
        #   translate: {f.pin.x + 20, f.pin.y + 20 + 60}
        # )

        # |> ScenicWidgets.TextPad.add_to_graph(
        #   %{
        #     frame:
        #       Widgex.Frame.new(
        #         pin: {10, 10 + 60},
        #         size: {f.size.width - 20, f.size.height - 20 - 60}
        #       ),
        #     state:
        #       ScenicWidgets.TextPad.new(%{
        #         # mode: :read_only,
        #         mode: :edit,
        #         text: t.data,
        #         font: body_font()
        #       })
        #   },
        #   id: {:data, t.uuid},
        #   # translate: {f.pin.x, f.pin.y}
        #   translate: f.pin.point
        # )
    end
  end

  def body_font do
    # TODO dont do this here, pass it in from the config

    # TODO...
    {:ok, ibm_plex_mono_font_metrics} =
      TruetypeMetrics.load("./assets/fonts/IBM_Plex_Mono/IBMPlexMono-Regular.ttf")

    # TODO make this more efficient, pass it in same everywhere
    ascent = FontMetrics.ascent(36, ibm_plex_mono_font_metrics)

    %{
      name: :ibm_plex_mono,
      size: 24,
      metrics: ibm_plex_mono_font_metrics,
      ascent: ascent
    }
  end

  # def draw_neo_card_background(graph, f) do
  #   radius = 20

  #   graph
  #   # Fill the box with color
  #   |> Scenic.Primitives.rrect(
  #     {f.size.width - 20, f.size.height - 20, radius},
  #     fill: :black,
  #     translate: {f.pin.x + 10, f.pin.y + 10}
  #   )
  #   |> Scenic.Primitives.rrect(
  #     {f.size.width - 20, f.size.height - 20, radius},
  #     stroke: {4, :blue},
  #     fill: :transparent,
  #     translate: {f.pin.x + 10, f.pin.y + 10}
  #   )
  # end

  def draw_neo_card_background(graph, f) do
    radius = 20
    header_height = 60
    heading = "description"
    # Adjust the text size as needed
    text_size = 24

    # Calculate the coordinates for centering the text
    text_x = f.pin.x + f.size.width / 2 - String.length(heading) * text_size / 4
    text_y = f.pin.y + header_height / 2 + text_size / 2 + 10

    graph
    # Fill the main card body with black
    |> Scenic.Primitives.rrect(
      {f.size.width - 20, f.size.height - 20, radius},
      fill: :black,
      translate: {f.pin.x + 10, f.pin.y + 10}
    )
    # Fill the header section with grey
    |> Scenic.Primitives.rrect(
      {f.size.width - 20, header_height, radius},
      fill: :grey,
      translate: {f.pin.x + 10, f.pin.y + 10}
    )
    # Stroke the card with a blue border
    |> Scenic.Primitives.rrect(
      {f.size.width - 20, f.size.height - 20, radius},
      stroke: {4, :blue},
      fill: :transparent,
      translate: {f.pin.x + 10, f.pin.y + 10}
    )
    # Draw a blue line under the header
    |> Scenic.Primitives.line(
      {{f.pin.x + 10, f.pin.y + 10 + header_height},
       {f.pin.x + f.size.width - 10, f.pin.y + 10 + header_height}},
      stroke: {2, :blue}
    )
    # Add centered text in the header
    |> Scenic.Primitives.text(
      heading,
      font_size: text_size,
      # You can change this to another color if needed
      fill: :white,
      translate: {text_x, text_y}
    )
  end

  def draw_card_background(graph, %Widgex.Frame{} = f) do
    graph
    |> Scenic.Primitives.rect(
      f.size.box,
      fill: :grey,
      translate: f.pin.point
    )
    |> Scenic.Primitives.rrect(
      {f.size.width - 20, f.size.height - 20, 20},
      stroke: {2, :grey},
      fill: :transparent,
      translate: {f.pin.x + 10, f.pin.y + 10}
    )
    # Fill the box with color
    |> Scenic.Primitives.rrect(
      {f.size.width - 20, f.size.height - 20, 20},
      fill: :black,
      translate: {f.pin.x + 10, f.pin.y + 10}
    )
  end

  def draw_hist_fn do
    fn graph, %{frame: f, tidbit: t} = args ->
      # reverse history so that the most recent updates render up the top
      bullets =
        if is_nil(t.history) do
          []
        else
          t.history
          # sometimes history is a binary, sometimes it's a map
          |> Enum.map(fn
            h_log when is_binary(h_log) ->
              h_log

            %{"timestamp" => ts, "log" => log} ->
              ts <> "\n" <> log
          end)
          |> Enum.reverse()
        end

      graph
      |> draw_basic_card(f, %{header: "History", bullets: bullets})
    end
  end

  def draw_basic_card(graph, %Widgex.Frame{} = f, %{header: h_text, bullets: bullets}) do
    # header_text = "History"
    header_font_size = 32

    box_width = f.size.width
    center_x = f.pin.x + box_width / 2

    # hack because sometimes history can be nil, even though it isn't supposed to be it should always be an empty list, but some old memexes have it...
    bullets = bullets || []

    graph
    |> Scenic.Primitives.rect(
      f.size.box,
      fill: :grey,
      translate: f.pin.point
    )
    |> Scenic.Primitives.rrect(
      {f.size.width - 20, f.size.height - 20, 20},
      stroke: {2, :grey},
      fill: :transparent,
      translate: {f.pin.x + 10, f.pin.y + 10}
    )
    # Fill the box with color
    |> Scenic.Primitives.rrect(
      {f.size.width - 20, f.size.height - 20, 10},
      fill: :black,
      translate: {f.pin.x + 10, f.pin.y + 10}
    )
    # Draw the centered header text
    |> Scenic.Primitives.text(h_text,
      font: :ibm_plex_mono,
      font_size: header_font_size,
      fill: :white,
      translate: {center_x, f.pin.y + 50},
      text_align: :center
    )
    # Add the bullet-pointed action list
    |> draw_bullet_points(f, bullets)
  end

  def draw_action_list_fn do
    fn graph, %{frame: f, actions: actions} = args ->
      # Calculate the center for the header text
      header_text = "Action List"
      header_font_size = 32

      box_width = f.size.width
      center_x = f.pin.x + box_width / 2

      # Draw the outer round-rectangle with margin
      graph
      |> Scenic.Primitives.rect(
        f.size.box,
        fill: :grey,
        translate: f.pin.point
      )
      |> Scenic.Primitives.rrect(
        {f.size.width - 20, f.size.height - 20, 20},
        stroke: {2, :grey},
        fill: :transparent,
        translate: {f.pin.x + 10, f.pin.y + 10}
      )
      # Fill the box with color
      |> Scenic.Primitives.rrect(
        {f.size.width - 20, f.size.height - 20, 10},
        fill: :black,
        translate: {f.pin.x + 10, f.pin.y + 10}
      )
      # Draw the centered header text
      |> Scenic.Primitives.text(header_text,
        font: :ibm_plex_mono,
        font_size: header_font_size,
        fill: :white,
        translate: {center_x, f.pin.y + 50},
        text_align: :center
      )
      # Add the bullet-pointed action list
      |> draw_bullet_points(f, actions)
    end
  end

  defp draw_bullet_points(graph, frame, lines) when is_list(lines) do
    # Starting y-position below the header
    start_y = frame.pin.y + 90
    # Adjust space between bullet points
    bullet_spacing = 90

    Enum.reduce(lines, graph, fn ln, g ->
      bullet_y = start_y + bullet_spacing * Enum.find_index(lines, fn x -> x == ln end)

      g
      # small circle for bullet point
      |> Scenic.Primitives.circle(5,
        fill: :white,
        # Position for the bullet point
        translate: {frame.pin.x + 20, bullet_y - 9}
      )
      |> Scenic.Primitives.text(ln,
        font: :ibm_plex_mono,
        font_size: 24,
        fill: :white,
        # Position for the text next to the bullet point
        translate: {frame.pin.x + 35, bullet_y}
      )
    end)
  end

  def old_render(graph, %{
        frame: %Widgex.Frame{} = f,
        state: %Memelex.TidBit{} = t
      }) do
    graph
    |> render_raw_tidbit(f, t)
    |> render_tools(f)
  end

  def render_raw_tidbit(graph, frame, %Memelex.TidBit{} = t) do
    graph
    |> Scenic.Primitives.group(
      fn graph ->
        graph
        # |> Widgex.Frame.draw_guidewires(f, color: :purple)
        |> Scenic.Primitives.text("#{prettify_map(t)}",
          font: :ibm_plex_mono,
          font_size: 24,
          fill: :white,
          translate: {20, 50}
        )
      end,
      translate: frame.pin.point
    )
  end

  @spacing 180
  def render_tools(graph, %Widgex.Frame{} = f) do
    graph
    |> Scenic.Primitives.group(
      fn graph ->
        graph
        |> Scenic.Components.button("Lower priority", id: :lower_priority, t: {10, 10})
        |> Scenic.Components.button("Higher priority",
          id: :higher_priority,
          t: {10 + @spacing, 10}
        )
        |> Scenic.Components.button("Add Due date",
          id: :sample_btn_id,
          t: {10 + 2 * @spacing, 10}
        )
        |> Scenic.Components.button("Consequences",
          id: :sample_btn_id,
          t: {10 + 3 * @spacing, 10}
        )
        ## next row
        |> Scenic.Components.button("Create sub-task", id: :sample_btn_id, t: {10, 60})
        |> Scenic.Components.button("Blockers", id: :sample_btn_id, t: {10 + 1 * @spacing, 60})
        |> Scenic.Components.button("Req'd resources",
          id: :sample_btn_id,
          t: {10 + 2 * @spacing, 60}
        )
        |> Scenic.Components.button("Apply label",
          id: :sample_btn_id,
          t: {10 + 3 * @spacing, 60}
        )
        ## next row
        |> Scenic.Components.button("Last movement", id: :sample_btn_id, t: {10, 110})
        |> Scenic.Components.button("Next action", id: :sample_btn_id, t: {10 + 1 * @spacing, 110})
      end,
      # translate: {20, f.size.height - 200}
      translate: {f.pin.x + 20, f.pin.y + f.size.height - 200}
    )
    # close button
    |> Scenic.Components.button("Close", id: :close, t: {450, 20})
  end

  def prettify_map(map) when is_map(map) do
    map
    |> Inspect.Algebra.to_doc(%Inspect.Opts{pretty: true, width: 80})
    |> Inspect.Algebra.format(80)
    |> IO.iodata_to_binary()
  end
end
