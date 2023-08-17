defmodule Flamelex.GUI.RootScene do
  @moduledoc false
  use Scenic.Scene
  use ScenicWidgets.ScenicEventsDefinitions
  import Scenic.Primitives
  import Scenic.Components
  alias ScenicWidgets.Core.Structs.Frame
  alias ScenicWidgets.Core.Utils.FlexiFrame
  alias Widgex.Structs.LayerCake
  require Logger

  # NOTE:
  # This Scenic.Scene contains the root graph. Re-drawing anything which
  # is rendered at the root level, required updating the state of this
  # process.  It is also responsible for capturing user-input (this is
  # just how Scenic behaves), which then gets forwarded to FluxusRadix -
  # since FluxusRadix holds the global state, and we need that to lookup
  # what to do with this input, as illustrated below:
  #
  #     %{}  +  %Keystroke{}  ->  %Action{}
  #
  #
  # TODO document the layers system
  # root scene doesn't subscribe to changes, it just spins up 7 layer processes
  # these _do_ subscribe to changes, specifically, just the change in their layer ;)
  # Flamelex.Lib.Utils.PubSub.subscribe(topic: :radix_state_change)

  # Scenic sends us lots of keypresses etc... easiest to just filter them
  # out right where they're detected (i.e. here), otherwise they clog up
  # things like keystroke history etc...

  # This trick to this module is the %Layer{} component which we wrap all
  # the graphs in. When a layer needs to change, it get's picked up by the
  # %Layer{} component, not the RootScene

  def init(init_scene, args, opts) do
    # Logger.debug("#{__MODULE__} initializing...")

    # NOTE - due to the way Scenic works right now, it's not practical to pass in the RadixState from the highest level of the SUpervision tree
    # Maybe in the future this could change but for now just fetch this data when the Scenc boots... this is also kind of nice incase the GUI gets reset

    # TODO we should return the radix_state here to save us from having to fetch it again in like 5 lines time
    Flamelex.Fluxus.RadixStore.put_viewport(init_scene.viewport)
    # TODO put this in radix state? gui.theme?
    init_theme = ScenicWidgets.Utils.Theme.get_theme(opts)
    radix_state = Flamelex.Fluxus.RadixStore.get()

    # We update a few details in the RadixStore which are
    # force-refreshed due to this process starting up
    {:ok, root_graph} = render_layers(radix_state)

    # Flamelex.Fluxus.RadixStore.put_root_graph(graph: root_graph)

    new_scene =
      init_scene
      |> assign(graph: root_graph)
      |> push_graph(root_graph)

    request_input(new_scene, [:viewport, :cursor_button, :cursor_scroll, :key])

    {:ok, new_scene}
  end

  # def handle_call(:get_viewport, _from, scene) do
  #    {:reply, {:ok, scene.viewport}, scene}
  # end

  def handle_input({:viewport, {:enter, _coords}}, context, scene) do
    # Logger.debug "#{__MODULE__} ignoring `:viewport_enter`..."
    {:noreply, scene}
  end

  def handle_input({:viewport, {:exit, _coords}}, context, scene) do
    # Logger.debug "#{__MODULE__} ignoring `:viewport_exit`..."
    {:noreply, scene}
  end

  # e.g. of new_dimensions: {1025, 818}
  def handle_input(
        {:viewport, {:reshape, {new_width, new_height} = new_dimensions}},
        context,
        scene
      ) do
    # Logger.debug "#{__MODULE__} received :viewport :reshape, dim: #{inspect new_dimensions}"

    new_viewport = %{scene.viewport | size: new_dimensions}
    Flamelex.Fluxus.RadixStore.update_viewport(new_viewport)

    {:noreply, %{scene | viewport: new_viewport}}
  end

  def handle_input({:key, {key, @key_released, _opts}}, _context, scene) do
    # Ignore key releases
    # Logger.debug "#{__MODULE__} `key_released` for keypress: #{inspect key}"
    {:noreply, scene}
  end

  def handle_input({:key, {key, @key_held, []}} = input, context, scene) do
    # If we hold down any kind of valid text input, pretend we just pressed it again
    # # If this works, she's a pearla!

    # the list of keys we can hold down and have the action repeat
    hold_downable_keys = @valid_text_input_characters ++ [@backspace_key]

    equivalent_key_press = {:key, {key, @key_pressed, []}}

    if Enum.member?(hold_downable_keys, equivalent_key_press) do
      # NOTE: It's vitally important we remember to recursively call
      # ourselves with the *equivalent_key_pressed_input* here :P
      handle_input(equivalent_key_press, context, scene)
    else
      Logger.warn(
        "#{__MODULE__} the key: #{inspect(key)} is being held, however `key_pressed` not valid"
      )

      {:noreply, scene}
    end
  end

  def handle_input(input, context, scene) do
    # Logger.debug "#{__MODULE__} recv'd some (non-ignored) input: #{inspect input}"
    Flamelex.Fluxus.input(input)
    {:noreply, scene}
  end

  # TODO this is the MainEntry for rendering the graph - this is the highest level
  # function, where we map from radix_state to the graph
  def render_layers(radix_state) do
    # [
    #   %LayerCake{
    #     layer: {:zero, "Layer One"},
    #     layout: :layout,
    #     state: %LayerZero.State{},
    #     frame: nil
    #   }
    # ]

    # Note that this list is ordered, so that it readws nicely
    # for humans - the firstt entry in this list will show _on top_
    # of the other layers, but for it to show up top it actually gets drawn *last*,
    # trhis is why we reverse the list at the end of this function
    # [
    #   kommander_layer(radix_state),
    #   menubar_layer(radix_state),
    #   working_layer(radix_state),

    # ]
    # |> Enum.reverse()

    full_graph =
      Scenic.Graph.build()
      |> base_layer(:renseijin, radix_state)

    # |> working_layer(radix_state)
    # |> menubar_layer(radix_state)
    # |> kommander_layer(radix_state)

    {:ok, full_graph}
  end

  def base_layer(graph, :renseijin, radix_state) do
    layer_state = Flamelex.GUI.Component.Renseijin.State.cast(radix_state)

    graph
    |> render_layer(radix_state, Flamelex.GUI.Layers.LayerZero.cast(radix_state))
  end

  def working_layer(graph, radix_state) do
    graph
    |> render_layer(radix_state, %LayerCake{
      id: :working_layer,
      # layer: {:working, "Working"},
      layout: %Widgex.Structs.GridLayout{},
      state: %{}
    })
  end

  def menubar_layer(graph, radix_state) do
    graph
    |> render_layer(radix_state, %LayerCake{
      # layer: {:menu, "Menu"},
      id: :menubar,
      layout: %Widgex.Structs.GridLayout{},
      state: %{}
    })
  end

  def kommander_layer(graph, radix_state) do
    graph
    |> render_layer(radix_state, %LayerCake{
      # layer: {:kommander, "Kommander"},
      id: :kommander,
      layout: %Widgex.Structs.GridLayout{},
      state: %{}
    })
  end

  def render_layer(graph, radix_state, %LayerCake{id: l_id} = layer) do
    graph
    |> Flamelex.GUI.Component.Layer.add_to_graph({radix_state, layer}, id: l_id)
  end
end
