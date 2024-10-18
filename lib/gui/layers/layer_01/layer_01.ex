defmodule Flamelex.GUI.Layers.Layer01 do
  use Scenic.Component
  alias Flamelex.GUI.Layers.Layer01
  require Logger

  # is it efficient to be passing around such a big radix state?
  # maybe I need to break the state down into different structs (backed by different store processes??)
  # or maybe I need to have a way to only pass the relevant parts of the state to each layer,
  # or maybe I can just call and get state as I need it from the UI components??? The
  # appeal of this idea to me is that, the state shouldn't live in the GUI,
  # if the GUI crashes wouldn't we want it to reboot and fetch fresh state
  # from some other part of the app? Right now that's always done by the root
  # process grabbing the radix state, but what if each component fetched it's
  # state from an equivalent store process, and those store processes could a) force a refresh of the GUI
  # or b) the GUI could force a refresh of the store processes / fetch fresh data whenever it needs it
  def validate(%{frame: %Widgex.Frame{}, state: %Layer01.State{}} = data) do
    {:ok, data}
  end

  def init(
        %Scenic.Scene{} = scene,
        %{frame: %Widgex.Frame{} = frame, state: %Layer01.State{} = state},
        opts
      ) do
    {:ok, new_graph} = render(frame, state)

    new_scene =
      scene
      |> assign(frame: frame)
      |> assign(state: state)
      |> assign(graph: new_graph)
      |> push_graph(new_graph)

    Flamelex.Lib.Utils.PubSub.subscribe(topic: :radix_state_change)

    {:ok, new_scene}
  end

  # the variable `l1_state` exactly matches in both places
  # of the pattern-match, therefore no state change occured
  def handle_info(
        {:radix_state_change, %{layers: %{one: l1_state}}},
        %{assigns: %{state: l1_state}} = scene
      ) do
    {:noreply, scene}
  end

  def handle_info(
        {:radix_state_change, %{layers: %{one: new_l1_state}}},
        %{assigns: %{frame: f}} = scene
      ) do
    case render(f, new_l1_state) do
      {:ok, %Scenic.Graph{} = new_graph} ->
        new_scene =
          scene
          |> assign(state: new_l1_state)
          |> assign(graph: new_graph)
          |> push_graph(new_graph)

        {:noreply, new_scene}

      {:error, reason} ->
        Logger.error("#{__MODULE__} failed to render. #{inspect(reason)}")
        {:noreply, scene}
    end
  end

  def render(frame, state) do
    Scenic.Graph.build()
    |> render(frame, state)
  end

  def render(graph, _frame, %{active_apps: []} = _layer_state) do
    {:ok, graph}
  end

  # def render(graph, frame, %{layout: :full_screen, active_apps: [{module, state} | _rest]})
  #     when is_atom(module) do
  #   # for full screen just let the first app take up the whole frame
  #   IO.puts("DEPRECATE MEEEEEE GET COMPONENT TO FETCH ITS STATE DONT PASS IT IN")

  #   Wormhole.capture(fn ->
  #     IO.puts("Rendering full screen #{inspect(module)}")

  #     graph
  #     |> module.add_to_graph(%{frame: frame, state: state})
  #   end)
  # end

  def render(graph, frame, %{layout: :full_screen, active_apps: [app | _rest]}) do
    # for full screen just let the first app take up the whole frame
    Wormhole.capture(fn ->
      graph
      |> app.add_to_graph(%{frame: frame})
    end)
  end

  def render(graph, frame, %{layout: :split_screen, active_apps: [app1, app2]}) do
    # layer_state.active_apps
    # |> Enum.reduce(
    #   blank_graph,
    #   fn app when is_atom(app), graph ->
    #     graph
    #     |> app.add_to_graph(%{
    #       frame: frame,
    #       state: app.State.new()
    #     })
    #   end
    # )

    Wormhole.capture(fn ->
      [left_frame, right_frame] = Widgex.Frame.h_split(frame)

      graph
      |> app1.add_to_graph(%{frame: left_frame})
      |> app2.add_to_graph(%{frame: right_frame})
    end)
  end

  def render(_f, state) do
    Logger.error("Unrecognised Layer State:\n\n#{prettify_map(state)}")
    {:error, "Unrecognised Layer State"}
  end

  defp prettify_map(map) when is_map(map) do
    map
    |> Inspect.Algebra.to_doc(%Inspect.Opts{pretty: true, width: 80})
    |> Inspect.Algebra.format(80)
    |> IO.iodata_to_binary()
  end
end

# def handle_info(
#       {:radix_state_change, new_radix_state},
#       %{assigns: %{frame: f, state: layer_state}} = scene
#     ) do
#   case Wormhole.capture(fn -> cast_rdx_to_layer_state(new_radix_state) end,
#          crush_report: true
#        ) do
#     {:ok, ^layer_state} ->
#       cast_children(scene, new_radix_state)
#       {:noreply, scene}

#     {:ok, new_layer_state} ->
#       # only re-render the frame (and therefore, all sub-components) if a layer-level change occured e.g. the layout shifted
#       {:ok, %Scenic.Graph{} = new_graph} = render(f, new_layer_state)

#       new_scene =
#         scene
#         |> assign(state: new_layer_state)
#         |> assign(graph: new_graph)
#         |> push_graph(new_graph)

#       {:noreply, new_scene}

#     {:error, _reason} ->
#       {:noreply, scene}
#   end
# end

# def handle_info({:radix_state_change, _new_radix_state}, scene) do
#   Logger.debug("#{__MODULE__} ignoring a RadixState change...")
#   {:noreply, scene}
# end

# def cast_rdx_to_layer_state(%{
#       menubar: %{height: menubar_h},
#       layers: %{one: %{turbo?: turbo?, active_apps: []}}
#     }) do
#   %{turbo?: turbo?, active_apps: [], menubar: %{height: menubar_h}}
# end

# only compute things of consequence to the _layer_ not the apps on this layer
# def cast_rdx_to_layer_state(%{
#       menubar: %{height: menubar_h},
#       layers: %{
#         one: %{
#           turbo?: turbo?,
#           layout: layout,
#           active_apps: active_apps
#         }
#       }
#     }) do
#   %{
#     turbo?: turbo?,
#     layout: layout,
#     active_apps: active_apps,
#     menubar: %{height: menubar_h}
#   }
# end

# def render(
#       frame,
#       %{
#         layout: :full_screen,
#         active_apps: [TODOlist]
#       } = layer_state
#     ) do
#   # we can't use the entire screen when the menubar is visible
#   # app_frame = calc_app_frame(full_window_frame, layer_state)

#   # scroll now "works" but it causes these graphs to re-draw constantly :(
#   graph =
#     Scenic.Graph.build()
#     |> Flamelex.GUI.Component.TODOlist.add_to_graph(%{
#       frame: frame,
#       # state: app_args |> Map.merge(%{turbo?: layer_state.turbo?})
#       state:
#     })

#   {:ok, graph}
# end

# def render(
#       full_window_frame,
#       %{
#         layout: :full_screen,
#         active_apps: [{Flamelex.GUI.Component.TODOlist, app_args}]
#       } = layer_state
#     ) do
#   # we can't use the entire screen when the menubar is visible
#   app_frame = calc_app_frame(full_window_frame, layer_state)

#   graph =
#     Scenic.Graph.build()
#     |> Flamelex.GUI.Component.TODOlist.add_to_graph(%{
#       frame: app_frame,
#       state: app_args |> Map.merge(%{turbo?: layer_state.turbo?})
#     })

#   {:ok, graph}
# end

# TODO ok the way this works, it should only re-draw the layer if the apps change, not if the args to those apps change!

# def render(
#       full_window_frame,
#       %{
#         layout: :split_screen,
#         active_apps: [
#           # {Flamelex.GUI.Component.TODOlist, %{list: todo_list}},
#           {Flamelex.GUI.Component.TODOlist, todo_args},
#           {Flamelex.GUI.Component.TODOdetails, details_args}
#         ]
#       } = layer_state
#     ) do
#   # we can't use the entire screen when the menubar is visible
#   app_frame = calc_app_frame(full_window_frame, layer_state)
#   [todo_frame, details_frame] = Frame.h_split(app_frame)

#   # TODO this could perhaps be automated if each component onlyt ever took in one argument `args`
#   graph =
#     Scenic.Graph.build()
#     |> Flamelex.GUI.Component.TODOlist.add_to_graph(%{
#       frame: todo_frame,
#       state: todo_args |> Map.merge(%{turbo?: layer_state.turbo?})
#     })
#     |> Flamelex.GUI.Component.TODOdetails.add_to_graph(%{
#       frame: details_frame,
#       state: details_args
#     })

#   {:ok, graph}
# end

# # this one is good! It's generic enough to handle any active app
# def render(
#       full_window_frame,
#       %{layout: :full_screen, active_apps: [{component_module, args}]} = layer_state
#     ) do
#   app_frame = calc_app_frame(full_window_frame, layer_state)

#   graph =
#     Scenic.Graph.build()
#     |> component_module.add_to_graph(%{
#       frame: app_frame,
#       state: args
#     })

#   {:ok, graph}
# end

# def calc_todo_widgets(todo_list) do
#   todo_widgets =
#     todo_list
#     |> Enum.map(fn t ->
#       {HyperCard, %{frame: nil, tidbit: t}}
#     end)
# end
