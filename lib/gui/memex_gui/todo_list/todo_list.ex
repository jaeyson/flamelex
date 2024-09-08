defmodule Flamelex.GUI.Component.TODOlist do
  @moduledoc """
  A GUI component for managing my TODO list.
  """
  use Scenic.Component
  alias Widgex.Frame
  alias Flamelex.GUI.Components.NeoHyperCard

  # TODO accept `selected` as an argument & change background opr whjatever when it's selected
  # def validate(%{frame: %Frame{} = _f, state: %{items: _i}} = data) do
  def validate(%{frame: %Frame{} = _f, state: %{list: todos}} = data) when is_list(todos) do
    # Logger.debug "#{__MODULE__} accepted params: #{inspect data}"
    {:ok, data}
  end

  # def get_current_todo do
  #   GenServer.call(__MODULE__, :get_selected_todo)
  # end

  def init(scene, args, opts) do
    init_graph = init_render(args)

    init_scene =
      scene
      |> assign(graph: init_graph)
      |> assign(frame: args.frame)
      # |> assign(theme: theme)
      |> assign(state: args.state)
      |> push_graph(init_graph)

    # Flamelex.Lib.Utils.PubSub.subscribe(topic: :radix_state_change)

    {:ok, scene}
  end

  # def handle_call(:get_selected_todo, _from, %{selected: %Memelex.TidBit{} = t} = state) do
  #   {:reply, t, state}
  # end

  def init_render(args) do
    [title_frame, tools_frame, list_frame] = calc_layout_frames(args.frame)

    Scenic.Graph.build()
    # |> Frame.draw_guidewires(args.frame, color: :blue)
    |> render_title(title_frame, "My TODOs")
    |> render_todo_list(list_frame, args)
    # render tools last because it needs to be drawn on top of the app layer due to dropdown menus
    |> render_tools(tools_frame, "tools")
  end

  def calc_layout_frames(%Frame{} = component_frame) do
    title_frame = calc_title_frame(component_frame)
    tools_frame = calc_tools_frame(component_frame, title_frame)
    list_frame = calc_list_frame(component_frame, title_frame, tools_frame)

    [title_frame, tools_frame, list_frame]
  end

  def calc_title_frame(component_frame) do
    Frame.new(%{
      pin: component_frame.pin.point,
      size: {
        component_frame.size.width,
        0.1 * component_frame.size.height
      }
    })
  end

  def calc_tools_frame(component_frame, title_frame) do
    Frame.new(%{
      pin: {
        component_frame.pin.x,
        component_frame.pin.y + title_frame.size.height
      },
      # temporarily increase the size of this frame so I dont have to solve the dropdown menu box problem yet
      size: {
        component_frame.size.width,
        0.1 * component_frame.size.height
      }
    })
  end

  def calc_list_frame(component_frame, title_frame, tools_frame) do
    # 5 percent margins

    # ten percent of the page going to the title
    # list_frame_h = 0.1 * component_frame.size.height

    # margin = 0.01

    Frame.new(%{
      pin: {
        component_frame.pin.x,
        component_frame.pin.y + title_frame.size.height + tools_frame.size.height
      },
      size: {
        component_frame.size.width,
        0.8 * component_frame.size.height
      }
    })
  end

  def render_title(graph, frame, title) do
    graph
    |> Scenic.Primitives.group(
      fn graph ->
        graph
        # |> Frame.draw_guidewires(frame)
        |> ScenicWidgets.Markup.Header1.draw(frame, title)

        # |> Scenic.Primitives.rect(frame.size.box, fill: :green)
        #  stroke: {border_stroke, stroke_color},
        #  translate: frame.pin
        # )
        # |> Scenic.Primitives.text(title,
        #   # font: font.name,
        #   font_size: 20,
        #   fill: :black,
        #   # translate: {0, 72}
        #   # translate: {5, font.ascent}
        # )
      end
      # translate: frame.pin.point
      # scissor: frame.size.box
    )
  end

  def render_tools(graph, frame, _t) do
    graph
    |> Scenic.Primitives.group(
      fn graph ->
        graph
        # |> Frame.draw_guidewires(frame, color: :green)
        # |> Scenic.Component.Input.Dropdown.add_to_graph(
        |> ScenicWidgets.SpareParts.LukesDropDown.add_to_graph(
          {[
             {"Top Ten", :top_ten},
             {"Oldest", :oldest},
             {"Most urgent", :most_urgent},
             {"Priority", :priority},
             {"Soonest deadline", :soonest},
             {"Un-prioritized", :un_prioritized},
             {"All", :all}
           ], :all},
          id: :filter_select,
          translate: {20, 20}
        )

        # |> Scenic.Primitives.rect(frame.size.box, fill: :green)
        #  stroke: {border_stroke, stroke_color},
        #  translate: frame.pin
        # )
        # |> Scenic.Primitives.text(title,
        #   # font: font.name,
        #   font_size: 20,
        #   fill: :black,
        #   # translate: {0, 72}
        #   # translate: {5, font.ascent}
        # )
      end,
      translate: frame.pin.point
      # scissor: frame.size.box
    )
  end

  @todo_height 60
  def render_todo_list(graph, frame, args) do
    todo_widgets =
      args.state.list
      |> Enum.with_index()
      |> Enum.map(fn {t, index} ->
        {NeoHyperCard,
         %{
           tidbit: t,
           frame:
             Widgex.Frame.new(%{
               size: {frame.size.width, @todo_height},
               pin: {0, @todo_height * index}
             })
         }}
      end)

    graph
    |> Scenic.Primitives.group(
      fn graph ->
        graph
        |> Frame.draw_guidewires(frame, color: :white)
        |> ScenicWidgets.VerticalList.add_to_graph(%{frame: frame, items: todo_widgets})
      end,
      translate: frame.pin.point
      # scissor: frame.size.box
    )
  end

  # TODO hacky but maybe will work, introduce de-bounding of clicked items here lol
  # if we get 2 clicks in certain number of milliseconds, then we can assume it's a double click
  # this might solve the issue where clicking a menubar item which is hovering over something below it triggers both
  def handle_cast({:click, %Memelex.TidBit{} = t}, %{assigns: %{dropdown_mode: true}} = scene) do
    IO.puts("IGNOREING THE CLICK CSUE WE'RE IN DROPDOWN MODE")
    # {:noreply, scene}
    # Flamelex.Fluxus.action({[app: __MODULE__], {:open_todo, t}})
    {:noreply, scene}
  end

  def handle_cast({:click, %Memelex.TidBit{} = t}, scene) do
    Flamelex.Fluxus.action({[app: __MODULE__], {:open_todo, t}})
    {:noreply, scene}
  end

  def handle_cast({:focus, _id}, scene) do
    # this is a bit of a hack but basically when the dropdown
    # drops it will msg the todo list (it's parent), we
    # set the whole component into dropdown mode, and in dropdown
    # mode we dont handle clicks from anything except the dropdown
    # - this will hopefully fix the bug ("workaround") where clicking
    # on a dropdown also clicks the item (usually a TODO) below it (in the z plane)
    {:noreply, scene |> assign(dropdown_mode: true)}
  end

  def handle_event({:value_changed, :filter_select, filter_by}, _context, scene) do
    #         GenServer.cast(Flamelex.GUI.Component.Memex.HyperCard.Sidebar.SearchResults, {:search, value})
    #         {:noreply, scene}
    #     end
    # IO.inspect("#{inspect(e)}")
    Flamelex.Fluxus.action({[app: __MODULE__], {:filter_todos, filter_by}})
    {:noreply, scene}
  end

  # def handle_event(e, scene) do
  #   IO.inspect("#{inspect(e)}")
  #   {:noreply, scene}
  # end

  # def handle_info(msg, scene) do
  #   IO.inspect("#{inspect(msg)}")
  #   {:noreply, scene}
  # end
end
