defmodule Flamelex.GUI.Layers.NeoLayer01 do
  use Widgex.Layer
  alias Flamelex.GUI.Components.NeoHyperCard, as: HyperCard

  require Logger

  def cast_rdx_to_layer_state(%{
        menubar: %{height: menubar_h},
        layers: %{one: %{turbo?: turbo?, active_apps: []}}
      }) do
    %{turbo?: turbo?, active_apps: [], menubar: %{height: menubar_h}}
  end

  def cast_rdx_to_layer_state(%{
        menubar: %{height: menubar_h},
        layers: %{
          one: %{
            turbo?: turbo?,
            layout: layout,
            active_apps: active_apps
          }
        }
      }) do
    %{
      turbo?: turbo?,
      layout: layout,
      active_apps: active_apps,
      menubar: %{height: menubar_h}
    }
  end

  # def cast_rdx_to_layer_state(%{
  #       menubar: %{height: menubar_h},
  #       layers: %{
  #         one: %{
  #           layout: :full_screen,
  #           active_app: {Flamelex.GUI.Component.TODOlist, todo_list}
  #         }
  #       }
  #     }) do
  #   %{
  #     layout: :full_screen,
  #     active_app: {Flamelex.GUI.Component.TODOlist, todo_list},
  #     menubar: %{height: menubar_h}
  #   }
  # end

  # def cast_rdx_to_layer_state(%{
  #       menubar: %{height: menubar_h},
  #       layers: %{
  #         one: %{
  #           active_app: nil
  #         }
  #       }
  #     }) do
  #   %{menubar: %{height: menubar_h}}
  # end

  # NOTE having an intermediate component which listens to memelex events vs radix state holding everything...
  # I'm just gonna go all in on radix state & see where that breaks - it's simpler & I _need_ to start making actual progress on this project...

  def render(frame, %{active_apps: []} = _layer_state) do
    # Logger.debug("Rendering layer 1 when the active app was set to nil...")

    graph =
      Scenic.Graph.build()
      |> Scenic.Primitives.rectangle(frame.size.box, fill: :blue)

    {:ok, graph}
  end

  def render(
        full_window_frame,
        %{
          layout: :full_screen,
          active_apps: {Flamelex.GUI.Component.TODOlist, app_args}
        } = layer_state
      ) do
    # we can't use the entire screen when the menubar is visible
    app_frame = calc_app_frame(full_window_frame, layer_state)

    graph =
      Scenic.Graph.build()
      |> Flamelex.GUI.Component.TODOlist.add_to_graph(%{
        frame: app_frame,
        state: app_args |> Map.merge(%{turbo?: layer_state.turbo?})
      })

    {:ok, graph}
  end

  def render(
        full_window_frame,
        %{
          layout: :full_screen,
          active_apps: [{Flamelex.GUI.Component.TODOlist, app_args}]
        } = layer_state
      ) do
    # we can't use the entire screen when the menubar is visible
    app_frame = calc_app_frame(full_window_frame, layer_state)

    graph =
      Scenic.Graph.build()
      |> Flamelex.GUI.Component.TODOlist.add_to_graph(%{
        frame: app_frame,
        state: app_args |> Map.merge(%{turbo?: layer_state.turbo?})
      })

    {:ok, graph}
  end

  def render(
        full_window_frame,
        %{
          layout: :split_screen,
          active_apps: [
            # {Flamelex.GUI.Component.TODOlist, %{list: todo_list}},
            {Flamelex.GUI.Component.TODOlist, todo_args},
            {Flamelex.GUI.Component.TODOdetails, details_args}
          ]
        } = layer_state
      ) do
    # we can't use the entire screen when the menubar is visible
    app_frame = calc_app_frame(full_window_frame, layer_state)
    [todo_frame, details_frame] = Frame.h_split(app_frame)

    # TODO this could perhaps be automated if each component onlyt ever took in one argument `args`
    graph =
      Scenic.Graph.build()
      |> Flamelex.GUI.Component.TODOlist.add_to_graph(%{
        frame: todo_frame,
        # state: %{items: calc_todo_widgets(todo_list)}
        state: todo_args |> Map.merge(%{turbo?: layer_state.turbo?})
      })
      |> Flamelex.GUI.Component.TODOdetails.add_to_graph(%{
        frame: details_frame,
        state: details_args
      })

    {:ok, graph}
  end

  # this one is good! It's generic enough to handle any active app
  def render(
        full_window_frame,
        %{layout: :full_screen, active_apps: [{component_module, args}]} = layer_state
      ) do
    app_frame = calc_app_frame(full_window_frame, layer_state)

    graph =
      Scenic.Graph.build()
      |> component_module.add_to_graph(%{
        frame: app_frame,
        state: args
      })

    {:ok, graph}
  end

  def render(_f, layer_state) do
    Logger.error("Unrecognised LayerState:\n\n#{prettify_map(layer_state)}")
    graph = Scenic.Graph.build()
    {:ok, graph}
  end

  def prettify_map(map) when is_map(map) do
    map
    |> Inspect.Algebra.to_doc(%Inspect.Opts{pretty: true, width: 80})
    |> Inspect.Algebra.format(80)
    |> IO.iodata_to_binary()
  end

  def calc_app_frame(full_window_frame, %{menubar: %{height: menubar_h}}) do
    [_menubar_frame, app_frame] = Frame.v_split(full_window_frame, px: menubar_h)

    app_frame
  end

  def calc_todo_widgets(todo_list) do
    todo_widgets =
      todo_list
      |> Enum.map(fn t ->
        {HyperCard, %{frame: nil, tidbit: t}}
      end)
  end
end
