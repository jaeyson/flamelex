defmodule Flamelex.GUI do
  # various pre-defined screen resolutions
  @macbook_pro {1440, 855}
  # @window_size_macbook_pro_2 {1680, 1005}
  @monitor_32inch {2560, 1395}
  # with size 24 font
  @terminal_80col {800, 600}

  @doc """
  This is the Scenic Viewport config, passed in to Scenic when
  we start the application (via the Supervision tree.)
  """
  def viewport_config do
    [
      name: :main_viewport,
      size: Enum.random([@macbook_pro, @monitor_32inch, @terminal_80col]),
      default_scene: {Flamelex.GUI.RootScene, nil},
      drivers: [
        [
          module: Scenic.Driver.Local,
          window: [title: "Flamelex", resizeable: true],
          on_close: :stop_system
        ]
      ]
    ]
  end
end
