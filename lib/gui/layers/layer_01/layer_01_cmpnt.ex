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

  # TODO ok the way this works, it should only re-draw the layer if the apps change, not if the args to those apps change!
  # only compute things of consequence to the _layer_ not the apps on this layer

  def validate(
        %{
          frame: %Widgex.Frame{},
          state: %Layer01.State{}
        } = data
      ) do
    {:ok, data}
  end

  def init(
        %Scenic.Scene{} = scene,
        %{
          frame: %Widgex.Frame{} = frame,
          state: %Layer01.State{} = state
        },
        opts
      ) do
    {:ok, new_graph} = Layer01.Render.render(frame, state)

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

  # TODO the way I'm defining projects here is fucking bunk but it will work for proof of concept until I figure out what the clean way would be
  def handle_info(
        {:radix_state_change,
         %{layers: %{one: %{projects: [project_dir]} = new_l1_state}} = rdx_state},
        scene
      )
      when is_binary(project_dir) and project_dir != "" do
    scene = Layer01.Render.re_render(scene, rdx_state, {:project_view, project_dir})
    {:noreply, scene}
  end

  def handle_info(
        {:radix_state_change, %{layers: %{one: new_l1_state}}},
        %{assigns: %{frame: f}} = scene
      ) do
    # case render(f, new_l1_state) do
    case Layer01.Render.render(f, new_l1_state) do
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

  def handle_info(
        {:radix_state_change, %{layers: %{one: new_l1_state}}},
        %{assigns: %{frame: f}} = scene
      ) do
    case Layer01.Render.render(f, new_l1_state) do
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

# def calc_todo_widgets(todo_list) do
#   todo_widgets =
#     todo_list
#     |> Enum.map(fn t ->
#       {HyperCard, %{frame: nil, tidbit: t}}
#     end)
# end
