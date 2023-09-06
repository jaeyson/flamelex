# TODO move this to a Widgex module
defmodule Flamelex.GUI.Component.Layer do
  use Scenic.Component
  require Logger

  alias Widgex.Structs.LayerCake
  alias Widgex.Structs.Frame

  def validate({radix_state, %LayerCake{} = layer} = data) do
    {:ok, data}
  end

  def init(
        %Scenic.Scene{} = scene,
        # TODO rename layerable to layer_module or somethjing
        {radix_state, %LayerCake{layerable: layer_mod} = layer},
        opts
      ) do
    Logger.debug("#{__MODULE__} initializing...")

    # TODO fetch the theme coming in from the opts, and use it to set the primary_color
    # TODO pass opts here aswell
    # {:ok, %Scenic.Graph{} = new_graph} = layer_mod.render(radix_state, layer)

    {:ok, new_graph} =
      if layer_mod == Flamelex.GUI.Layers.Layer02 do
        layer_mod.render(radix_state.gui.viewport, layer.state)
      else
        layer_mod.render(radix_state, layer)
      end

    new_scene =
      scene
      |> assign(graph: new_graph)
      |> assign(layer: layer)
      |> push_graph(new_graph)

    request_input(new_scene, [:cursor_pos])

    {:ok, new_scene}
  end

  def init(scene, %{layer_module: layer_mod, radix_state: radix_state} = args, opts) do
    # Logger.debug "Initializing layer #{opts[:id]}..."

    init_state = layer_mod.cast(radix_state)

    {:ok, init_graph} =
      if layer_mod == Flamelex.GUI.Layers.Layer02 do
        layer_mod.render(radix_state.gui.viewport, init_state)
      else
        layer_mod.render(init_state, radix_state)
      end

    init_scene =
      scene
      # |> assign(id: opts[:id] || raise "invalid ID")
      # |> assign(layer: layer)
      |> assign(graph: init_graph)
      |> assign(state: init_state)
      |> push_graph(init_graph)

    Flamelex.Lib.Utils.PubSub.subscribe(topic: :radix_state_change)

    {:ok, init_scene}
  end

  # def init(scene, args, opts) do
  #    init_scene = scene
  #    |> assign(id: opts[:id] || raise "invalid ID")
  #    |> assign(render_fn: args.render_fn)
  #    |> assign(calc_state_fn: args[:calc_state_fn] || nil)
  #    |> assign(graph: args.graph)
  #    |> assign(state: args[:state] || nil)
  #    |> push_graph(args.graph)

  #    Flamelex.Lib.Utils.PubSub.subscribe(topic: :radix_state_change)

  #    {:ok, init_scene}
  # end

  # NOTE that this is better because it uses the "layer state" to figure out if it needs to change. Layer state doesn't need to change *all* the time e.g. if we input a single character... that can be handled by the Editor component
  def handle_info(
        {:radix_state_change, new_radix_state},
        # %{assigns: %{state: old_layer_state, layer: layer}} = scene
        %{
          assigns: %{
            state: old_layer_state,
            layer: %LayerCake{
              layerable: layer_mod
            }
          }
        } = scene
      ) do
    # NOTE here is where layer updates happen
    new_layer_state = layer_mod.cast(new_radix_state)

    if new_layer_state != old_layer_state do
      # case layer.render(new_layer_state, new_radix_state) do

      # this is a temp hack to just test out the new pattern on layer 2
      if layer_mod == Flamelex.GUI.Layers.Layer02 do
        viewport = new_radix_state.gui.viewport

        {:ok, %Scenic.Graph{} = new_graph} = layer_mod.render(viewport, new_layer_state)

        new_scene =
          scene
          |> assign(state: new_layer_state)
          |> assign(graph: new_graph)
          |> push_graph(new_graph)

        {:noreply, new_scene}
      else
        IO.inspect(layer_mod)

        case layer_mod.render({:radix_state, new_radix_state}, new_layer_state) do
          :ignore ->
            {:noreply, scene}

          {:ok, %Scenic.Graph{} = new_graph} ->
            new_scene =
              scene
              |> assign(state: new_layer_state)
              |> assign(graph: new_graph)
              |> push_graph(new_graph)

            {:noreply, new_scene}
        end
      end
    else
      {:noreply, scene}
    end
  end

  # def handle_info({:radix_state_change, %{root: %{layers: layer_list}}}, scene) do
  # def handle_info({:radix_state_change, new_radix_state}, scene) do

  #    dbg()
  #    # #ONE IDEA - instead of triggering by changings in the layer list, re-compute the graph for this layer and change if it's it's changed...
  #    recomputed_layer_graph = scene.assigns.render_fn.(new_radix_state)

  #    # this_layer = scene.assigns.id #REMINDER: this will be an atom, like `:one`
  #    # [{^this_layer, this_layer_graph}] =
  #    #    layer_list |> Enum.filter(fn {layer, _graph} -> layer == scene.assigns.id end)

  #    if scene.assigns.graph != recomputed_layer_graph do
  #       IO.puts "!!!LAYER CHANGE!!!"
  #       Logger.debug "#{__MODULE__} Layer: #{inspect scene.assigns.id} changed, re-drawing the RootScene..."

  #       new_scene = scene
  #       |> assign(graph: recomputed_layer_graph)
  #       |> push_graph(recomputed_layer_graph)

  #       {:noreply, new_scene}
  #    else
  #       #Logger.debug "Layer #{inspect scene.assigns.id}, ignoring.."
  #       {:noreply, scene}
  #    end
  # end

  def handle_info({:radix_state_change, _new_radix_state}, scene) do
    # Logger.debug "#{__MODULE__} ignoring a RadixState change..."
    {:noreply, scene}
  end
end
