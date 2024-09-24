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
  alias Memelex.GUI.Components.RapidSelector
  require Logger

  def validate(
        %{
          frame: %Widgex.Frame{} = _f
        } = data
      ) do
    # Logger.debug "#{__MODULE__} accepted params: #{inspect data}"

    {:ok, data}
  end

  def init(scene, %{frame: %Widgex.Frame{} = frame}, opts) do
    # state = Flamelex.Fluxus.RadixStore.get().apps.rapid_selector
    #     # TODO here, we should fetch the memelex app radix_state & use that going forward, also using that topic
    #     # dont worry about passing in memex state from above, in fact it wont exist at that level!!

    state = RapidSelector.State.new()
    graph = render(frame, state)

    init_scene =
      scene
      |> assign(graph: graph)
      |> assign(state: state)
      |> assign(frame: frame)
      |> push_graph(graph)

    Flamelex.Lib.Utils.PubSub.subscribe(topic: :radix_state_change)

    {:ok, init_scene}
  end

  def handle_info(
        {:radix_state_change, %{apps: %{rapid_selector: state}}},
        %{assigns: %{frame: f, state: state}} = scene
      ) do
    IO.puts("GETTING MSG BUT STATE IS SAME")
    # state variables in pattern match are the same, therefore no state change occured
    {:noreply, scene}
  end

  def handle_info(
        # {:radix_state_change, %{apps: %{rapid_selector: %RapidSelector.State{} = new_state}}},
        {:radix_state_change, %{apps: %{rapid_selector: new_state}}},
        %{assigns: %{frame: f}} = scene
      ) do
    # # TODO we shouldn't _always_ need to re-render.. should evaluate the changes first
    # diff = MapDiff.diff(scene.assigns.state, new_state)
    # # # IO.inspect(diff)
    # dbg()

    # if old_state.list == new_state.list

    # keep the old scroll
    # new_state = put_in(new_state, [:scroll], old_state.scroll)
    IO.puts("GETTING THE MSG")

    new_graph = render(f, new_state)

    new_scene =
      scene
      |> assign(graph: new_graph)
      |> assign(state: new_state)
      |> push_graph(new_graph)

    {:noreply, new_scene}
  end

  def handle_info(msg, scene) do
    IO.inspect(msg)
    {:noreply, scene}
  end

  def render(frame, %RapidSelector.State{} = state) do
    [left, mid_l, _mid, _mid_r, right] = Widgex.Frame.col_split(frame, 5)

    middle_three =
      Widgex.Frame.new(%{
        pin: mid_l.pin,
        size: {3 * mid_l.size.width, mid_l.size.height}
      })

    Scenic.Graph.build()
    |> Memelex.GUI.Components.CollectionsMantel.add_to_graph(%{
      frame: left,
      state: %{}
    })
    |> Memelex.GUI.Components.StoryRiver.add_to_graph(%{
      frame: middle_three,
      state: state.story_river
    })
    |> Memelex.GUI.Component.Memex.SideBar.add_to_graph(%{
      frame: right,
      state: state
    })

    # |> Scenic.Primitives.text("Memelex",
    #    font: :ibm_plex_mono,
    #    # font: args.font.name,
    #    # font_size: args.font.size,
    #    # fill: args.theme.text,
    #    fill: :white,
    #    # TODO this is what scenic does https://github.com/boydm/scenic/blob/master/lib/scenic/component/input/text_field.ex#L198
    #    translate: {100, 100}
    # )
  end
end
