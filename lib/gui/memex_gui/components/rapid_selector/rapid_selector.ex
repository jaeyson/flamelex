defmodule Memelex.GUI.Components.RapidSelector do
  @moduledoc """
  ## Rapid Selector: An interface inspired by Vannevar Bush's Vision

  The **Rapid Selector** is the primary interface for navigating, selecting, and interacting with knowledge stored in this memex system. The name is inspired by concepts from Vannevar Bush's famous paper *"As We May Think"*, written in 1945, where he described the potential of a hypothetical device called the **Memex**—an early vision of a hypertext system for linking and retrieving information.

  ### Why "Rapid Selector"?

  In Bush's vision, future technology would allow users to **rapidly retrieve** information from vast repositories of knowledge, much like the microfilm technology of his time, but faster and more intuitively. The **Rapid Selector** is a tribute to this idea of quickly and precisely selecting relevant pieces of information, without the friction that traditional interfaces might impose.

  - **Rapid**: This refers to the system's goal of enabling quick, efficient access to stored knowledge, allowing the user to pull up content with minimal delay.
  - **Selector**: Emphasizing the role of the user in **choosing** what information is most relevant at any given time. It reinforces the interactivity and control the user has over their memex.

  In essence, the Rapid Selector is more than just a display—it’s an active tool that allows you to explore your personal knowledge archive with speed and precision.

  ### Features:
  - **Speed**: Instant access to knowledge, making exploration seamless.
  - **Precision**: Allows for fine-grained selection of relevant content, as you rapidly move between linked data points.
  - **Organization**: Inspired by both analog and digital concepts of information storage (microfilm, cassettes, etc.), the interface provides an intuitive means of visualizing and managing data.

  Whether you’re familiar with the original vision or not, the Rapid Selector empowers you to organize, retrieve, and explore your own memex efficiently.

  """
  use Scenic.Component
  alias Memelex.GUI.Components.RapidSelector.State
  require Logger

  def validate(
        %{
          frame: %Widgex.Frame{} = _f,
          state: %State{} = _state
        } = data
      ) do
    # Logger.debug "#{__MODULE__} accepted params: #{inspect data}"
    {:ok, data}
  end

  def init(scene, args, opts) do
    Logger.debug("#{__MODULE__} initializing...")

    # pubsub_mod = Module.concat(args.app, Utils.PubSub)
    # pubsub_mod.subscribe(topic: :radix_state_change)

    init_graph = render(args)

    # init_state =
    #   calc_state(args.radix_state)

    init_scene =
      scene
      #   |> assign(app: args.app)
      #   |> assign(font: args.radix_state.editor.font)
      #   |> assign(frame: args.frame)
      |> assign(graph: init_graph)
      #   |> assign(state: init_state)
      |> push_graph(init_graph)

    {:ok, init_scene}
  end

  def render(%{frame: frame, state: memex_state}) do
    #  [left_bar | other_frames] = FlexiFrame.columns(frame, 3, :memex)
    #  [middle_section | right_pane] = other_frames
    #  right_pane = hd(right_pane)
    [left_bar, middle_section, right_pane] = Widgex.Frame.col_split(frame, 3)

    Scenic.Graph.build()
    # |> ScenicWidgets.FrameBox.add_to_graph(%{frame: left_bar, fill: :purple})
    # |> ScenicWidgets.FrameBox.add_to_graph(%{frame: middle_section, fill: :yellow})
    |> Memelex.GUI.Components.CollectionsMantel.add_to_graph(%{
      frame: left_bar,
      state: %{}
    })
    |> Memelex.GUI.Components.StoryRiver.add_to_graph(%{
      frame: middle_section,
      state: memex_state.story_river
    })
    |> Memelex.GUI.Component.Memex.SideBar.add_to_graph(%{
      frame: right_pane,
      state: memex_state
    })

    # |> ScenicWidgets.FrameBox.add_to_graph(%{frame: right_pane, fill: :red})

    # |> Scenic.Primitives.text("Memelex",
    #    font: :ibm_plex_mono,
    #    # font: args.font.name,
    #    # font_size: args.font.size,
    #    # fill: args.theme.text,
    #    fill: :white,
    #    # TODO this is what scenic does https://github.com/boydm/scenic/blob/master/lib/scenic/component/input/text_field.ex#L198
    #    translate: {100, 100}
    # )

    #         |> Memex.SideBar.add_to_graph(%{
    #                 frame: right_quadrant(args.frame),
    #                 state: args.state.sidebar})

    # |> Scenic.Primitives.line({{10, 10}, {200, 200}}, stroke: {1, :white})
  end
end
