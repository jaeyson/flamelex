defmodule Flamelex.GUI.DevTools do
  @moduledoc """
  `Flamelex.GUI.DevTools` provides a set of developer tools for use within the Flamelex GUI system.

    These tools are designed to assist in the development and debugging of GUI elements,
  enabling features such as visual debugging, component inspection, and layout management.

  ## Features

  - **Component Inspector**: Allows developers to inspect the state and properties of GUI components.
  - **Layout Manager**: Provides tools for dynamically adjusting and visualizing the layout of GUI components.
  - **Event Logger**: Logs GUI events for debugging purposes.
  - **Performance Monitor**: Monitors the rendering and processing performance of the GUI.

  Includes tools for generating new GUI components following the Flux pattern.
  """

  @doc """
  Initializes the developer tools within the Flamelex GUI.

  This function should be called during the setup of the GUI to enable developer tool features.
  """
  def init_dev_tools do
    # Initialization logic for developer tools
    raise "not implemented"
  end

  # This will clean and recompile everything, but it will be part of a cold restart, as it's more of a recompilation process.
  # However, this isn't hot code reloading in the strict sense, where the system keeps running without downtime while code is reloaded.
  def recompile_all_deps do
    Mix.Task.run("deps.clean", ["--all"])
    Mix.Task.run("clean")
    Mix.Task.run("deps.get")
    Mix.Task.run("compile", ["--force"])
  end

  def recompile_dep(dependency_name) do
    Mix.Task.run("deps.clean", [dependency_name])
    # Mix.Task.run("deps.clean", [dependency_name])
  end

  def reboot_viewport do
    {:ok, vp} = Process.whereis(:main_viewport) |> Scenic.ViewPort.info()
    {:ok, _} = Scenic.ViewPort.set_root(vp, Flamelex.GUI.RootScene, %{})
    :ok
  end

  @doc """
  Opens the component inspector, which displays information about the selected GUI components.

  This can be used to examine the properties and state of any component within the GUI.
  """
  def open_component_inspector(component) do
    # Logic to inspect the component
    raise "not implemented"
  end

  def open_widget_wkb do
    # Flamelex.Fluxus.action({WidgetWorkbench, :open})
    {:ok, vp} = Process.whereis(:main_viewport) |> Scenic.ViewPort.info()
    {:ok, _} = Scenic.ViewPort.set_root(vp, WidgetWorkbench.Scene, %{})
    :ok
  end

  # call this to restore the flamelex GUI after you've been playing with the widget workbench
  def restore_flamelex do
    {:ok, vp} = Process.whereis(:main_viewport) |> Scenic.ViewPort.info()
    :ok = Scenic.ViewPort.set_root(vp, Flamelex.GUI.RootScene, %{})
    :ok
  end

  def temet_nosce do
    recompile_dep("memelex")
    recompile_dep("scenic-widget-contrib")
    Mix.Task.run("deps.get")
    IEx.Helpers.recompile()
    reboot_viewport()
  end

  @doc """
  Toggles the layout manager, which allows developers to visually manipulate the layout of components.

  This feature enables the dynamic adjustment of layouts during development.
  """
  def toggle_layout_manager do
    # Logic to toggle layout manager
    raise "not implemented"
  end

  @doc """
  Starts the event logger, which logs all events that occur within the GUI for debugging purposes.

  Developers can use this to trace event handling and identify issues.
  """
  def start_event_logger do
    # Logic to start logging GUI events
    raise "not implemented"
  end

  @doc """
  Starts the performance monitor, tracking the rendering and processing performance of the GUI.

  This is useful for identifying performance bottlenecks.
  """
  def start_performance_monitor do
    # Logic to start monitoring performance
    raise "not implemented"
  end

  @doc """
  Creates a new GUI component by generating the necessary files.

  ## Parameters

    - `component_name`: The name of the new component as an atom or string.

  ## Example

      Flamelex.GUI.DevTools.build_new_component(:todo_list)
  """
  def build_new_component(component_name)
      when is_binary(component_name) do
    # when is_atom(component_name) or is_binary(component_name) do
    # Convert the component name to a string and format it
    component_name_str =
      component_name
      # |> to_string()
      |> String.replace(" ", "")
      |> Macro.camelize()

    # Prepare module and file names
    module_base = "Flamelex.GUI.Component.#{component_name_str}"
    file_base = Macro.underscore(component_name_str)

    # Define base paths
    base_path = "lib/gui/components/#{file_base}"
    File.mkdir_p!(base_path)

    # List of files to create with their content generators
    files = [
      {Path.join(base_path, "#{file_base}_cmpnt.ex"), component_module_content(module_base)},
      {Path.join(base_path, "#{file_base}_state.ex"), state_module_content(module_base)},
      {Path.join(base_path, "#{file_base}_reducer.ex"), reducer_module_content(module_base)},
      {Path.join(base_path, "#{file_base}_mutator.ex"), mutator_module_content(module_base)},
      {Path.join(base_path, "#{file_base}_render.ex"), render_module_content(module_base)},
      {Path.join(base_path, "#{file_base}_user_input_handler.ex"),
       user_input_handler_content(module_base)}
    ]

    # Create each file with its content
    Enum.each(files, fn {file_path, content} ->
      if File.exists?(file_path) do
        IO.puts("File already exists: #{file_path}")
      else
        File.write!(file_path, content)
        IO.puts("Created file: #{file_path}")
      end
    end)

    # TODO
    # now what would be amazingly ninja would be to add it to the radix state programatically...

    :ok
  end

  # Helper functions to generate file contents

  defp component_module_content(module_base) do
    """
    defmodule #{module_base} do
      @moduledoc \"\"\"
      A GUI component for #{humanize_module_name(module_base)}.
      \"\"\"

      use Scenic.Component
      require Logger
      alias Widgex.Frame
      alias Scenic.Graph
      alias Flamelex.Fluxus.RadixState
      alias #{module_base}
      alias #{module_base}.State
      alias #{module_base}.Render
      alias Flamelex.GUI.Utils.Draw

      # Validate function for Scenic component
      def validate(%{frame: %Frame{}} = data) do
        {:ok, data}
      end

      def init(scene, %{frame: %Frame{} = frame}, _opts) do
        state = Flamelex.Fluxus.RadixStore.get().apps.#{module_base |> Macro.underscore() |> String.split("/") |> List.last()}
        graph = Render.go(frame, state)

        init_scene =
          scene
          |> assign(frame: frame)
          |> assign(graph: graph)
          |> assign(state: state)
          |> push_graph(graph)

        Flamelex.Lib.Utils.PubSub.subscribe(topic: :radix_state_change)

        {:ok, init_scene}
      end

      # Handle state changes where the state hasn't changed
      def handle_info(
            {:radix_state_change, %{apps: %{#{module_base |> Macro.underscore() |> String.split("/") |> List.last()}: state}}},
            %{assigns: %{frame: frame, state: state}} = scene
          ) do
        # State variables in pattern match are the same; no state change occurred
        {:noreply, scene}
      end

      # Handle state changes where the state has changed
      def handle_info(
            {:radix_state_change, %{apps: %{#{module_base |> Macro.underscore() |> String.split("/") |> List.last()}: new_state}}},
            %{assigns: %{frame: frame, state: old_state}} = scene
          ) do
        # State has changed; raise an error as handling is app-specific
        raise "State change handling not implemented in template"
        {:noreply, scene}
      end
    end
    """
  end

  defp state_module_content(module_base) do
    """
    defmodule #{module_base}.State do
      @moduledoc \"\"\"
      State management for the #{humanize_module_name(module_base)} component.
      \"\"\"

      use StructAccess

      defstruct [
        # Define state fields here
      ]

      def new do
        %__MODULE__{}
      end
    end
    """
  end

  defp reducer_module_content(module_base) do
    """
    defmodule #{module_base}.Reducer do
      @moduledoc \"\"\"
      Processes actions and updates the Radix state for the #{humanize_module_name(module_base)} component.
      \"\"\"

      alias Flamelex.Fluxus.RadixState
      alias #{module_base}
      alias #{module_base}.Mutator

      def process(%RadixState{} = rdx, action) do
        case action do
          # Match on specific actions and call mutators
          _ ->
            rdx
        end
      end
    end
    """
  end

  defp mutator_module_content(module_base) do
    """
    defmodule #{module_base}.Mutator do
      @moduledoc \"\"\"
      Functions to mutate the Radix state for the #{humanize_module_name(module_base)} component.
      \"\"\"

      alias Flamelex.Fluxus.RadixState

      def some_mutation(%RadixState{} = rdx, params) do
        # Perform state mutation
        raise "not implemented"
      end
    end
    """
  end

  defp render_module_content(module_base) do
    """
    defmodule #{module_base}.Render do
      @moduledoc \"\"\"
      Functions to render the %Scenic.Graph{} for #{humanize_module_name(module_base)} component.
      \"\"\"

      alias #{module_base}.State
      alias Flamelex.Fluxus.RadixState
      alias Flamelex.GUI.Utils.Draw

      def go(%Widgex.Frame{} = f, %State{} = _state) do
        Scenic.Graph.build()
        |> Scenic.Primitives.group(
          fn graph ->
            graph
            |> Draw.background(f, :medium_slate_blue)
            |> Widgex.Frame.draw_guidewires(f)
            |> Scenic.Primitives.text("#{module_base}",
              font_size: 24,
              translate: {f.size.width / 2, f.size.height / 2}
            )
          end,
          translate: f.pin.point
        )
      end
    end
    """
  end

  defmodule Flamelex.GUI.Component.AgentHuddle.Render do
    alias Flamelex.GUI.Component.AgentHuddle.State
    alias Flamelex.GUI.Utils.Draw
  end

  defp user_input_handler_content(module_base) do
    """
    defmodule #{module_base}.UserInputHandler do
      @moduledoc \"\"\"
      Handles user input for the #{humanize_module_name(module_base)} component.
      \"\"\"

      require Logger
      use ScenicWidgets.ScenicEventsDefinitions
      alias #{module_base}
      alias #{module_base}.Reducer

      def handle(rdx, input) do
        case input do
          # Match on specific inputs and return actions
          _ ->
            Logger.warn("\#{__MODULE__} received unhandled input: \#{inspect(input)}")
            :ignore
        end
      end
    end
    """
  end

  # Helper function to humanize module names
  defp humanize_module_name(module_name) do
    module_name
    |> String.split(".")
    |> List.last()
    |> Macro.underscore()
    |> String.replace("_", " ")
    |> String.capitalize()
  end
end
