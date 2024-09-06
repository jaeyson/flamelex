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

  alias Flamelex.GUI.Layers.NeoLayer01
  alias Flamelex.GUI.Layers.NeoLayer02

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

  def init(scene, args, opts) do
    # Logger.debug("#{__MODULE__} initializing...")

    # NOTE - due to the way Scenic works right now, it's not practical to pass in the RadixState from the highest level of the SUpervision tree
    # Maybe in the future this could change but for now just fetch this data when the Scenc boots... this is also kind of nice incase the GUI gets reset

    # TODO we should return the radix_state here to save us from having to fetch it again in like 5 lines time
    # Flamelex.Fluxus.RadixStore.put_viewport(init_scene.viewport)
    # TODO put this in radix state? gui.theme?
    # init_theme = ScenicWidgets.Utils.Theme.get_theme(opts)
    # radix_state = Flamelex.Fluxus.RadixStore.get()
    {:ok, radix_state} = GenServer.call(Flamelex.Fluxus.Radix, :get_state)

    # We update a few details in the RadixStore which are
    # force-refreshed due to this process starting up
    {:ok, root_graph} = render_layers(scene.viewport, radix_state)

    new_scene =
      scene
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

  def handle_input({:viewport, {:reshape, _size}}, context, scene) do
    Logger.debug("#{__MODULE__} ignoring `:viewport_reshape`...")
    {:noreply, scene}
  end

  # e.g. of new_dimensions: {1025, 818}
  # def handle_input(
  #       {:viewport, {:reshape, {new_width, new_height} = new_dimensions}},
  #       context,
  #       scene
  #     ) do
  #   # Logger.debug "#{__MODULE__} received :viewport :reshape, dim: #{inspect new_dimensions}"

  #   new_viewport = %{scene.viewport | size: new_dimensions}
  #   Flamelex.Fluxus.RadixStore.update_viewport(new_viewport)

  #   {:noreply, %{scene | viewport: new_viewport}}
  # end

  # Ignore key releases
  def handle_input({:key, {key, @key_released, _opts}}, _context, scene) do
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
    # Logger.debug("#{__MODULE__} recv'd some (non-ignored) input: #{inspect(input)}")
    Flamelex.Fluxus.user_input(input)
    {:noreply, scene}
  end

  # TODO this is the MainEntry for rendering the graph - this is the highest level
  # function, where we map from radix_state to the graph
  def render_layers(viewport, radix_state) do
    # Note that this list is ordered, so that it readws nicely
    # for humans - the firstt entry in this list will show _on top_
    # of the other layers, but for it to show up top it actually gets drawn *last*,
    # this is why we reverse the list at the end of this function

    full_window = Widgex.Frame.new(viewport)

    full_graph =
      Scenic.Graph.build()
      |> NeoLayer01.add_to_graph(%{
        id: :apps,
        frame: full_window,
        # we can use this to resize the frame to accomodate menubar space, once I get that working again...
        # frame: NeoLayer01.compute_frame(viewport, radix_state),
        state: NeoLayer01.cast_rdx_to_layer_state(radix_state)
        # pubsub: Flamelex.Lib.Utils.PubSub
      })
      |> NeoLayer02.add_to_graph(%{
        id: :menubar,
        frame: full_window,
        # we can use this to resize the frame to accomodate menubar space, once I get that working again...
        # frame: NeoLayer01.compute_frame(viewport, radix_state),
        state: NeoLayer02.cast_rdx_to_layer_state(radix_state)
        # pubsub: Flamelex.Lib.Utils.PubSub
      })

    # |> second_layer(:menubar, radix_state)

    # |> kommander_layer(radix_state)

    {:ok, full_graph}
  end

  # def base_layer(graph, :renseijin, radix_state) do
  #   # layer_state = Flamelex.GUI.Component.Renseijin.State.cast(radix_state)

  #   graph
  #   |> render_layer(
  #     radix_state,
  #     Flamelex.GUI.Layers.LayerZero.cast(radix_state)
  #     # layer_state
  #   )
  # end

  # def working_layer(graph, radix_state) do
  #   graph
  #   |> render_layer(radix_state, %LayerCake{
  #     id: :working_layer,
  #     # layer: {:working, "Working"},
  #     layout: %Widgex.Structs.GridLayout{},
  #     state: %{}
  #   })
  # end

  # def first_layer(graph, :editor_and_apps, radix_state) do
  #   # state = Flamelex.GUI.Layers.Layer01.cast(radix_state)

  #   # # TODO should be cast...
  #   # layer_cake =
  #   #   LayerCake.new(%{
  #   #     "id" => :editor_and_apps,
  #   #     "state" => state,
  #   #     "layerable" => Flamelex.GUI.Layers.Layer01
  #   #   })

  #   # graph |> do_render_layer(radix_state, layer_cake)

  #   graph
  #   |> Flamelex.GUI.Layers.NeoLayer01.add_to_graph(radix_state)
  # end

  # def second_layer(graph, :menubar, radix_state) do
  #   # TODO actually, cast is the real name of this function, we should use that, shoud blog about that...
  #   # what I mean by this is, that "cast" is transmute, it means 'change the type' or to 'change the form'
  #   state = Flamelex.GUI.Layers.Layer02.cast(radix_state)

  #   layer_cake =
  #     LayerCake.new(%{
  #       "id" => :menubar,
  #       "state" => state,
  #       "layerable" => Flamelex.GUI.Layers.Layer02
  #     })

  #   graph |> do_render_layer(radix_state, layer_cake)

  #   #     |> render_layer(radix_state, %LayerCake{
  #   #   # layer: {:menu, "Menu"},
  #   #   id: :menubar,
  #   #   layout: %Widgex.Structs.GridLayout{},
  #   #   state: %{}
  #   # })

  #   # |> render_layer(
  #   #   radix_state,
  #   #   Flamelex.GUI.Layers.Layer02.cast(radix_state)
  #   # )
  # end

  # def kommander_layer(graph, radix_state) do
  #   # graph
  #   # |> render_layer(
  #   #   radix_state,
  #   #   Flamelex.GUI.Layers.Layer03.cast(radix_state)
  #   # )

  #   # TODO THIS ONE is the best interfact here, this module
  #   # should implement a behaviour which abstracts away all common
  #   # layer behaviour, but it doesnt makse sense having one layer
  #   # component which accepts a streuct with module names, just
  #   # call the module but have that behaviour ("wink wink!") abstracted away
  #   # but call the module itself directly
  #   # Flamelex.GUI.Layers.Layer03.stack_layer(graph, radix_state)

  #   layer_cake =
  #     LayerCake.new(%{
  #       "id" => :kommander,
  #       "state" => Flamelex.GUI.Layers.Layer03.cast(radix_state),
  #       "layerable" => Flamelex.GUI.Layers.Layer03
  #     })

  #   graph |> do_render_layer(radix_state, layer_cake)
  # end

  # def render_layer(graph, radix_state, %LayerCake{id: l_id} = layer) do
  #   graph
  #   |> Flamelex.GUI.Component.Layer.add_to_graph({radix_state, layer}, id: l_id)
  # end

  # def do_render_layer(graph, radix_state, %LayerCake{id: l_id} = layer) do
  #   graph
  #   |> Flamelex.GUI.Component.Layer.add_to_graph({radix_state, layer}, id: l_id)
  # end
end
