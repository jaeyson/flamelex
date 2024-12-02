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
          frame: %Widgex.Frame{} = frame,
          # state: %Layer01.State{}
        } = data
      ) do
    {:ok, frame}
  end

  def init(
    %Scenic.Scene{} = scene,
    %Widgex.Frame{} = frame,
    _opts
  ) do

    # fetch a new fresh Layer state
    state = Flamelex.Fluxus.RadixStore.get().layers.one

    {:ok, new_graph} = Layer01.Renderizer.render(frame, state)

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
    scene = Layer01.Renderizer.re_render(scene, rdx_state, {:project_view, project_dir})
    {:noreply, scene}
  end

  def handle_info(
        {:radix_state_change, %{layers: %{one: new_l1_state}}},
        %{assigns: %{frame: f}} = scene
      ) do
    case Layer01.Renderizer.render(f, new_l1_state) do
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





# defmodule Flamelex.GUI.Layers.Layer01 do
#   @moduledoc """
#   This layer contains the Editor & other desktop apps.
#   """

#   # use ScenicWidgets.Fluxus.Layer

#   # @behaviour Flamelex.GUI.Layer.Behaviour

#   alias ScenicWidgets.Core.Utils.FlexiFrame
#   alias Widgex.Structs.LayerCake

#   # @impl Flamelex.GUI.Layer.Behaviour

#   defstruct active_app: nil,
#             menu_bar: %{
#               height: nil
#             },
#             # TODO editor state?
#             editor: %{
#               active_buf: nil
#             },
#             high_council: %{}

#   # explorer: %{
#   #   active?: false,
#   #   horizontal_split: {27, :percent}
#   # },
#   # layout: nil

#   # def cast(radix_state) do
#   #   IO.inspect(radix_state)

#   #   %__MODULE__{
#   #     active_app: radix_state.root.active_app,
#   #     editor: %{
#   #       active_buf: radix_state.editor.active_buf
#   #     },
#   #     menu_bar: %{
#   #       height: radix_state.desktop.menu_bar.height
#   #     }
#   #   }
#   # end

#   # def cast(%{root: %{layers: %{one: :split}}} = radix_state) do
#   #   # TODO here, this is gonna get split msg when we call Flamelex.API.Editor.split

#   #   IO.puts("CAST SPLITITITIT")

#   #   %{framestack: [_menubar_f | editor_f]} =
#   #     FlexiFrame.calc(
#   #       radix_state.gui.viewport,
#   #       {:standard_rule, linemark: radix_state.desktop.menu_bar.height}
#   #     )

#   #   frames = FlexiFrame.split(hd(editor_f))

#   #   # Then we change the state of the layer to be showing 2 buffers, and we update the render function to render 2 buffers!!
#   #   %{
#   #     layer: :one,
#   #     layout: :split,
#   #     frames: frames,
#   #     active_app: radix_state.root.active_app,
#   #     active_buf: radix_state.editor.active_buf
#   #   }
#   # end

#   # TODO in the new model, this would send a msg to RadixState, which would then call the reducer (in an async function handler)
#   def show_todo_list(radix_state, :full_screen) do
#     radix_state
#     |> put_in([:root, :layers, :one, :layout], %{todo_list: :full_screen})
#   end

#   # this is a cool experiment, we ought to have a layer which just controls the layer, and works by applying reducer to radix_state
#   # def show_todos(radix_state) do
#   #   radix_reducio(radix_state, :show_todos)
#   # end

#   # note that eventually we should just get passed in the radix state

#   def radix_reducio(radix_state, :show_todos) do
#     radix_state
#     |> put_in([:root, :layers, :one, :layout], %{todo_list: :full_screen})
#   end

#   def cast(
#         %{
#           root: %{
#             layers: %{
#               one: %{
#                 layout: %{
#                   explorer: %{active?: true},
#                   editor: :full_screen
#                 }
#               }
#             }
#           }
#         } = radix_state
#       ) do
#     main_pane =
#       FlexiFrame.main_pane_frame(radix_state.gui.viewport,
#         menu_bar_height: radix_state.desktop.menu_bar.height
#       )

#     # FlexiFrame.split(main_pane, horizontal: {32, :percent})
#     [left_pane, right_pane] = FlexiFrame.split_horizontal(main_pane, 27)

#     %{
#       layer: :one,
#       layout: :explorer_open,
#       frames: [
#         left_pane,
#         right_pane
#       ],
#       # layout: %{
#       #   explorer: left_pane,
#       #   editor: right_pane
#       # },
#       active_app: radix_state.root.active_app
#     }
#   end

#   def cast(%{root: %{layers: %{one: %{layout: %{editor: :full_screen}}}}} = radix_state) do
#     # calc the editor frame
#     %{framestack: [_menubar_f | editor_f]} =
#       FlexiFrame.calc(
#         radix_state.gui.viewport,
#         {:standard_rule, linemark: radix_state.desktop.menu_bar.height}
#       )

#     %{
#       layer: :one,
#       layout: :full_screen,
#       frame: hd(editor_f),
#       active_app: radix_state.root.active_app,
#       active_buf: radix_state.editor.active_buf
#     }
#   end

#   def cast(%{root: %{layers: %{one: %{layout: %{editor: :split}}}}} = radix_state) do
#     # calc the editor frame
#     %{framestack: [_menubar_f | editor_f]} =
#       FlexiFrame.calc(
#         radix_state.gui.viewport,
#         {:standard_rule, linemark: radix_state.desktop.menu_bar.height}
#       )

#     frames = FlexiFrame.split(hd(editor_f))

#     #   # Then we change the state of the layer to be showing 2 buffers, and we update the render function to render 2 buffers!!
#     #   %{
#     #     layer: :one,
#     #     layout: :split,
#     #     frames: frames,
#     #     active_app: radix_state.root.active_app,
#     #     active_buf: radix_state.editor.active_buf
#     #   }

#     %{
#       layer: :one,
#       layout: :split,
#       frames: frames,
#       active_app: radix_state.root.active_app,
#       active_buf: radix_state.editor.active_buf
#     }
#   end

#   def cast(%{root: %{layers: %{one: %{layout: %{todo_list: :full_screen}}}}} = radix_state) do
#     # calc the editor frame
#     %{framestack: [_menubar_f | editor_f]} =
#       FlexiFrame.calc(
#         radix_state.gui.viewport,
#         {:standard_rule, linemark: radix_state.desktop.menu_bar.height}
#       )

#     frames = FlexiFrame.split(hd(editor_f))

#     %{
#       layer: :one,
#       layout: :full_screen,
#       frames: full_screen(radix_state),
#       active_app: :todo_list
#       # active_buf: radix_state.editor.active_buf
#     }
#   end

#   # this isnt really the full screen, it's the full screen minus the menu bar
#   defp full_screen(radix_state) do
#     %{framestack: [_menubar_f | editor_f]} =
#       FlexiFrame.calc(
#         radix_state.gui.viewport,
#         {:standard_rule, linemark: radix_state.desktop.menu_bar.height}
#       )

#     hd(editor_f)
#   end

#   def render(_viewport, %{active_app: :desktop}) do
#     # don't render anything on this layer if the active app is :desktop
#     {:ok, Scenic.Graph.build()}
#   end

#   # def maybe_split(
#   #       graph,
#   #       editor_frame,
#   #       %{root: %{layers: %{one: %{layout: %{editor: :full_screen}}}}} = radix_state
#   #     ) do
#   #   graph
#   #   |> QuillEx.GUI.Components.Editor.add_to_graph(%{
#   #     frame: editor_frame,
#   #     radix_state: radix_state,
#   #     app: Flamelex
#   #   })
#   # end

#   # def maybe_split(
#   #       graph,
#   #       editor_frame,
#   #       %{root: %{layers: %{one: %{layout: %{editor: :split}}}}} = _radix_state
#   #     ) do
#   #   graph
#   #   |> QuillEx.GUI.Components.Editor.add_to_graph(%{
#   #     frame: editor_frame,
#   #     radix_state: radix_state,
#   #     app: Flamelex
#   #   })
#   # end

#   # def render({:radix_state, radix_state}, _frame, %{
#   #       active_app: :editor,
#   #       layout: :split,
#   #       frames: [f1 | f2]
#   #     }) do
#   #   IO.puts("SPLITLITLIT")
#   #   dbg()

#   #   {:ok,
#   #    Scenic.Graph.build()
#   #    |> QuillEx.GUI.Components.Editor.add_to_graph(%{
#   #      frame: f1,
#   #      radix_state: radix_state,
#   #      app: Flamelex
#   #    })
#   #    |> QuillEx.GUI.Components.Editor.add_to_graph(%{
#   #      frame: hd(f2),
#   #      radix_state: radix_state,
#   #      app: Flamelex
#   #    })}
#   # end

#   def render(
#         %Scenic.ViewPort{} = viewport,
#         %{active_app: :todo_list, layout: :full_screen, frames: f} = state
#       ) do
#     IO.puts("IF WE GET HERE THEN INEFFICINT AS IT IS< ITS WORKING")

#     new_graph =
#       Scenic.Graph.build()
#       # |> maybe_split(editor_frame, radix_state)

#       # # TODO this is the next big place we tackle...
#       |> Flamelex.GUI.MemexGUI.Components.TODOlist.add_to_graph({
#         %Flamelex.GUI.MemexGUI.Components.TODOlist{},
#         f
#         #   # radix_state: radix_state,
#         #   # app: Flamelex
#       })

#     {:ok, new_graph}
#   end

#   # def render(
#   #       {:radix_state, radix_state},
#   #       %{active_app: :editor, frame: frame}
#   #     ) do
#   #   {:ok,
#   #    Scenic.Graph.build()
#   #    |> QuillEx.GUI.Components.Editor.add_to_graph(%{
#   #      frame: frame,
#   #      radix_state: radix_state,
#   #      app: Flamelex
#   #    })}
#   # end

#   def render(
#         %Scenic.ViewPort{} = viewport,
#         %{active_app: :editor, layout: :full_screen} = state
#       ) do
#     IO.puts("ACTIVE APP EDITOR #{inspect(state)}")

#     %{framestack: [_menubar_f | editor_f]} =
#       FlexiFrame.calc(
#         viewport,
#         # {:standard_rule, linemark: state.menu_bar.height}
#         # TODO
#         {:standard_rule, linemark: 60}
#       )

#     # editor_f is always a tail list (for now...)
#     editor_frame = hd(editor_f)

#     # you know what fuck it
#     radix_state = Flamelex.Fluxus.RadixStore.get()

#     new_graph =
#       Scenic.Graph.build()
#       # |> maybe_split(editor_frame, radix_state)

#       # TODO this is the next big place we tackle...
#       |> QuillEx.GUI.Components.Editor.add_to_graph(%{
#         frame: editor_frame,
#         radix_state: radix_state,
#         app: Flamelex
#       })

#     {:ok, new_graph}
#   end

#   def render(
#         %Scenic.ViewPort{} = viewport,
#         %{active_app: :editor, layout: :split, frames: [f1 | f2]} = state
#       ) do
#     IO.puts("ACTIVE APP SPLITTTTT EDITOR #{inspect(state)}")

#     %{framestack: [_menubar_f | editor_f]} =
#       FlexiFrame.calc(
#         viewport,
#         # {:standard_rule, linemark: state.menu_bar.height}
#         # TODO
#         {:standard_rule, linemark: 60}
#       )

#     # editor_f is always a tail list (for now...)
#     editor_frame = hd(editor_f)

#     # you know what fuck it
#     radix_state = Flamelex.Fluxus.RadixStore.get()

#     new_graph =
#       Scenic.Graph.build()
#       |> QuillEx.GUI.Components.Editor.add_to_graph(%{
#         frame: f1,
#         radix_state: radix_state,
#         app: Flamelex
#       })
#       |> QuillEx.GUI.Components.Editor.add_to_graph(%{
#         frame: hd(f2),
#         radix_state: radix_state,
#         app: Flamelex
#       })

#     {:ok, new_graph}
#   end

#   # def render(
#   #       {:radix_state, radix_state},
#   #       %{active_app: :hexdocs, frame: frame}
#   #     ) do
#   #   {:ok,
#   #    Scenic.Graph.build()
#   #    |> Flamelex.GUI.Components.HexDocs.add_to_graph(%{
#   #      frame: frame,
#   #      state: %{}
#   #    })}
#   # end
