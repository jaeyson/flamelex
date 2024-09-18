defmodule Flamelex.GUI.Component.TODOlist do
  @moduledoc """
  A GUI component for managing my TODO list.
  """
  use Scenic.Component
  alias Widgex.Frame
  alias Flamelex.GUI.Components.NeoHyperCard
  alias Flamelex.GUI.Component.TODOlist
  alias Flamelex.Fluxus.TODOlistReducer

  # TODO accept `selected` as an argument & change background opr whjatever when it's selected
  # def validate(%{frame: %Frame{} = _f, state: %{items: _i}} = data) do
  def validate(
        %{
          frame: %Frame{} = _f
        } = data
      ) do
    # Logger.debug "#{__MODULE__} accepted params: #{inspect data}"
    # new_state = Map.merge(state, %{scroll: {0, 0}})
    # {:ok, assign(data, state: new_state)}
    # {:ok, %{data | state: new_state}}
    {:ok, data}
  end

  # def get_current_todo do
  #   GenServer.call(__MODULE__, :get_selected_todo)
  # end

  def init(scene, %{frame: %Frame{} = f}, opts) do
    state = Flamelex.Fluxus.RadixStore.get().apps.todo_list

    graph = render(f, state)

    init_scene =
      scene
      |> assign(frame: f)
      |> assign(graph: graph)
      |> assign(state: state)
      |> push_graph(graph)

    Flamelex.Lib.Utils.PubSub.subscribe(topic: :radix_state_change)

    {:ok, init_scene}
  end

  def handle_info(
        {:radix_state_change, %{apps: %{todo_list: state}}},
        %{assigns: %{frame: f, state: state}} = scene
      ) do
    # state variables in pattern match are the same, therefore no state change occured
    {:noreply, scene}
  end

  def handle_info(
        {:radix_state_change, %{apps: %{todo_list: new_state}}},
        %{assigns: %{frame: f, state: old_state}} = scene
      ) do
    # # TODO we shouldn't _always_ need to re-render.. should evaluate the changes first
    # diff = MapDiff.diff(scene.assigns.state, new_state)
    # # # IO.inspect(diff)
    # dbg()

    # if old_state.list == new_state.list

    # keep the old scroll
    new_state = put_in(new_state, [:scroll], old_state.scroll)

    new_graph = render(f, new_state)

    new_scene =
      scene
      |> assign(graph: new_graph)
      |> assign(state: new_state)
      |> push_graph(new_graph)

    {:noreply, new_scene}
  end

  def render(%Widgex.Frame{} = f, %TODOlist.State{} = state) do
    [title_frame, tools_frame, list_frame] = calc_layout_frames(f)

    Scenic.Graph.build()
    # |> Frame.draw_guidewires(args.frame, color: :blue)
    |> render_title(title_frame, "My TODOs")
    |> render_todo_list(list_frame, state)
    # render tools last because it needs to be drawn on top of the app layer due to dropdown menus
    |> render_tools(tools_frame, "tools")
  end

  # def init_render(args) do
  #   [title_frame, tools_frame, list_frame] = calc_layout_frames(args.frame)

  #   Scenic.Graph.build()
  #   # |> Frame.draw_guidewires(args.frame, color: :blue)
  #   |> render_title(title_frame, "My TODOs")
  #   |> render_todo_list(list_frame, args)
  #   # render tools last because it needs to be drawn on top of the app layer due to dropdown menus
  #   |> render_tools(tools_frame, "tools")
  # end

  def handle_cast({:radix_state_change, new_rdx}, scene) do
    # new_state = Map.merge(scene.assigns.state, %{scroll: new_scroll})
    IO.puts("TODO getting pushed msgs")
    {:noreply, scene}
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
        |> ScenicWidgets.Markup.Header1.draw(%{frame: frame, text: title})

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
             {"Newest", :newest},
             {"This week", :this_week},
             {"This month", :this_month},
             {"Next month", :next_month},
             {"Most urgent", :most_urgent},
             {"Overdue", :overdue},
             {"Random 5", :random_5},
             {"Priority", :priority},
             {"Soonest deadline", :soonest},
             {"Un-prioritized", :un_prioritized},
             # upcoming should show 3 columns, today, this month, this quarter, and then optionally 6 months 1 year 5 year 10 years
             {"Upcoming", :upcoming},
             {"Done", :done},
             {"Cancelled", :cancelled},
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
  def render_todo_list(graph, frame, state) do
    todo_widgets =
      state.list
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
        # |> Frame.draw_guidewires(frame, color: :white)
        |> ScenicWidgets.VerticalList.add_to_graph(%{
          id: VList,
          frame: frame,
          items: todo_widgets,
          scroll: state.scroll
        })
      end,
      # id: TODOlist,
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
    Flamelex.Fluxus.action({TODOlistReducer, {:open_todo, t}})
    {:noreply, scene}
  end

  # def handle_cast(
  #       {:cursor_scroll, TODOlist, {{_dx, dy} = delta_scroll, coords}},
  #       %{
  #         assigns: %{state: %{turbo?: true}}
  #       } = scene
  #     ) do
  #   fast_scroll = {0, 100 * dy}

  #   new_scroll =
  #     scene.assigns.scroll
  #     |> Scenic.Math.Vector2.add(delta_scroll)

  #   cast_children(scene, {:set_scroll, new_scroll})
  #   {:noreply, scene |> assign(scroll: new_scroll)}
  # end

  # def handle_cast({:cursor_scroll, TODOlist, {{_dx, dy} = delta_scroll, coords}}, scene) do
  #

  #   new_scroll =
  #     scene.assigns.scroll
  #     |> Scenic.Math.Vector2.add(delta_scroll)

  #   cast_children(scene, {:set_scroll, new_scroll})
  #   {:noreply, scene |> assign(scroll: new_scroll)}
  # end

  def handle_cast({:cursor_scroll, VList, {{_dx, dy} = delta_scroll, coords}}, scene) do
    # TODO consider actually sending this as an action throuigh Fluxus now....

    # TODO debate
    # there is some debate that I should send this scroll up to the top layer,
    # because maybe I dont want to scroll this maybe I want to scroll the whole page or something

    # and that is valid

    # however in this case, right here and now, I dont need to do that, and it's slow
    # and causes problems - I'm currently refactoring the entire way I store state
    # to work around this issue

    # we appreciate your patience in the mean time

    scroll_speed = if scene.assigns.state.turbo_scroll?, do: 100, else: 20

    new_scroll =
      scene.assigns.state.scroll
      |> Scenic.Math.Vector2.add({0, scroll_speed * dy})

    # Flamelex.Fluxus.action({__MODULE__, {:set_scroll, new_scroll}})

    # new_state = Map.merge(scene.assigns.state, %{scroll: new_scroll})
    # {:noreply, scene |> assign(state: new_state)}

    new_state = scene.assigns.state |> put_in([:scroll], new_scroll)

    cast_children(scene, {:set_scroll, new_scroll})
    {:noreply, scene |> assign(state: new_state)}

    # new_graph =
    #   scene.assigns.graph
    #   |> Scenic.Graph.modify(
    #     __MODULE__,
    #     &Scenic.Primitives.update_opts(&1, translate: new_scroll)
    #   )

    # new_state = scene.assigns.state |> put_in([:scroll], new_scroll)

    # new_scene =
    #   scene
    #   |> assign(graph: new_graph)
    #   |> assign(state: new_state)
    #   |> push_graph(new_graph)

    # {:noreply, scene}
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
    {:noreply, scene |> assign(filter: filter_by)}
  end

  # def handle_event(e, scene) do
  #   IO.inspect("#{inspect(e)}")
  #   {:noreply, scene}
  # end

  # def handle_info(msg, scene) do
  #   IO.inspect("#{inspect(msg)}")
  #   {:noreply, scene}
  # end

  # @fast_scroll_speed 20
  # def compute_scroll({_x, _y} = current_cumulative_scroll, {_dx, dy}) do
  #   # TODO cap scroll - right now we just dont allow negative scrolling

  #   # speed up scrolling, and we never scroll in x direction (yet)
  #   fast_scroll = {0, @fast_scroll_speed * dy}

  #   new_cumulative_scroll =
  #     current_cumulative_scroll
  #     |> Scenic.Math.Vector2.add(fast_scroll)

  #   case new_cumulative_scroll do
  #     {x, y} when y > 0 ->
  #       # we want to be able to scroll "down" the list but
  #       # not "up" past the starting point, therefore
  #       # we only allow negative y values when scrolling
  #       {x, 0}

  #     {x, y} ->
  #       {x, y}
  #   end
  # end
end
