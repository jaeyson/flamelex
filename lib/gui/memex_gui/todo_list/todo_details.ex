defmodule Flamelex.GUI.Component.TODOdetails do
  use Scenic.Component

  def validate(
        %{
          frame: %Widgex.Frame{} = _f
          # state: %Memelex.TidBit{} = _t
        } = data
      ) do
    # Logger.debug "#{__MODULE__} accepted params: #{inspect data}"
    {:ok, data}
  end

  def init(scene, %{frame: %Widgex.Frame{} = f}, opts) do
    todo = Flamelex.Fluxus.RadixStore.get().apps.todo_details
    state = %{todo: todo, scroll: {0, 0}}

    {:ok, graph} = render(f, state)

    init_scene =
      scene
      |> assign(graph: graph)
      |> assign(frame: f)
      |> assign(state: state)
      |> push_graph(graph)

    Flamelex.Lib.Utils.PubSub.subscribe(topic: :radix_state_change)

    {:ok, init_scene}
  end

  def handle_cast({:cursor_scroll, v_list, {{_dx, dy}, _coords}}, scene) do
    scroll_speed = 20

    new_scroll =
      scene.assigns.state.scroll
      |> Scenic.Math.Vector2.add({0, scroll_speed * dy})

    new_state = scene.assigns.state |> put_in([:scroll], new_scroll)

    cast_children(scene, {:set_scroll, new_scroll})
    {:noreply, scene |> assign(state: new_state)}
  end

  def handle_info(
        {:radix_state_change, %{apps: %{todo_details: %Memelex.TidBit{} = t}}},
        %{assigns: %{frame: f, state: %{todo: t}}} = scene
      ) do
    # state variables in pattern match are the same, therefore no state change occured
    {:noreply, scene}
  end

  def handle_info(
        {:radix_state_change, %{apps: %{todo_details: %Memelex.TidBit{} = new_t}}},
        %{assigns: %{frame: f, state: old_state}} = scene
      ) do
    # # TODO we shouldn't _always_ need to re-render.. should evaluate the changes first
    # new_state = put_in(old_state, [:todo], new_t)
    new_state = %{
      todo: new_t,
      # reset the scroll if we change the TidBit
      scroll: {0, 0}
    }

    {:ok, new_graph} = render(f, new_state)

    new_scene =
      scene
      |> assign(graph: new_graph)
      |> assign(state: new_state)
      |> push_graph(new_graph)

    {:noreply, new_scene}
  end

  def render(frame, state) do
    Scenic.Graph.build()
    |> render(frame, state)
  end

  # def render(graph, %Widgex.Frame{} = f, %{state: %Memelex.TidBit{} = t}) do
  def render(graph, %Widgex.Frame{} = f, %{todo: %Memelex.TidBit{} = t} = state) do
    Wormhole.capture(fn ->
      # todo_widgets =
      #   args.state.list
      #   |> Enum.map(fn t ->
      #     {NeoHyperCard, %{tidbit: t}}
      #   end)

      # title_h = 60
      title_h = 0.1 * f.size.height
      panel_h = 300

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

      blocks = [
        {ScenicWidgets.Markup.Header1,
         %{frame: Widgex.Frame.new(%{size: {f.size.width, title_h}, pin: {0, 0}}), text: t.title}},
        {draw_raw_tidbit,
         %{
           frame:
             Widgex.Frame.new(%{
               size: {f.size.width, 2 * panel_h},
               pin: {0, title_h + 0 * panel_h}
             })
         }},
        {draw_action_list_fn(),
         %{
           frame:
             Widgex.Frame.new(%{
               size: {f.size.width, 1.5 * panel_h},
               pin: {0, title_h + 2 * panel_h}
             }),
           actions: tidbit_actions
         }}

        # {ScenicWidgets.FrameBox,
        #  %{
        #    frame:
        #      Widgex.Frame.new(%{size: {f.size.width, 2 * panel_h}, pin: {0, title_h + 0 * panel_h}})
        #  }}
        # {ScenicWidgets.FrameBox,
        #  %{
        #    frame:
        #      Widgex.Frame.new(%{size: {f.size.width, panel_h}, pin: {0, title_h + 1 * panel_h}})
        #  }},
        # {ScenicWidgets.FrameBox,
        #  %{
        #    frame:
        #      Widgex.Frame.new(%{size: {f.size.width, panel_h}, pin: {0, title_h + 2 * panel_h}})
        #  }},
        # {ScenicWidgets.FrameBox,
        #  %{
        #    frame:
        #      Widgex.Frame.new(%{size: {f.size.width, panel_h}, pin: {0, title_h + 3 * panel_h}})
        #  }}
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

  defp draw_bullet_points(graph, frame, actions) do
    # Starting y-position below the header
    start_y = frame.pin.y + 90
    # Adjust space between bullet points
    bullet_spacing = 40

    Enum.reduce(actions, graph, fn action, g ->
      bullet_y = start_y + bullet_spacing * Enum.find_index(actions, fn x -> x == action end)

      g
      # small circle for bullet point
      |> Scenic.Primitives.circle(5,
        fill: :white,
        # Position for the bullet point
        translate: {frame.pin.x + 20, bullet_y - 9}
      )
      |> Scenic.Primitives.text(action,
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

  def handle_event({:click, :higher_priority}, _from, scene) do
    scene.assigns.state
    |> Memelex.My.Wiki.update(%{priority: :higher})

    {:noreply, scene}
  end

  def handle_event({:click, :close}, _from, scene) do
    Flamelex.Fluxus.action({[app: __MODULE__], :close_todo})
    {:noreply, scene}
  end

  def handle_event({:click, btn}, _from, scene) do
    IO.puts("Sample button was clicked in HANDLE EVENT! #{inspect(btn)}")
    {:noreply, scene}
  end

  def prettify_map(map) when is_map(map) do
    map
    |> Inspect.Algebra.to_doc(%Inspect.Opts{pretty: true, width: 80})
    |> Inspect.Algebra.format(80)
    |> IO.iodata_to_binary()
  end
end
