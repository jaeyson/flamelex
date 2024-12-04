defmodule Flamelex.GUI.Component.TODOdetails do
  use Scenic.Component
  alias Flamelex.Fluxus.RadixStore
  alias Flamelex.GUI.Component.TODOdetails

  def validate(
        %{
          frame: %Widgex.Frame{} = _f
        } = data
      ) do
    # Logger.debug "#{__MODULE__} accepted params: #{inspect data}"
    {:ok, data}
  end

  def init(scene, %{frame: %Widgex.Frame{} = frame}, opts) do
    state = RadixStore.get().apps.todo_details

    graph = TODOdetails.Renderizer.render(Scenic.Graph.build(), frame, state)

    init_scene =
      scene
      |> assign(graph: graph)
      |> assign(frame: frame)
      |> assign(state: state)
      |> push_graph(graph)

    Flamelex.Lib.Utils.PubSub.subscribe(topic: :radix_state_change)

    {:ok, init_scene}
  end

  def handle_cast({:cursor_scroll, v_list, {{_dx, dy}, _coords}}, scene) do
    scroll_speed = 20

    new_scroll =
      scene.assigns.state.scroll
      |> Scenic.Math.Vector2.add({0, scroll_speed * dy})

    new_state = scene.assigns.state |> put_in([:scroll], new_scroll)

    cast_children(scene, {:set_scroll, new_scroll})
    {:noreply, scene |> assign(state: new_state)}
  end

  def handle_cast({:click, {:edit, tidbit_uuid}}, scene) do
    Flamelex.Fluxus.action({__MODULE__, {:edit_todo, tidbit_uuid}})
    {:noreply, scene}
  end

  def handle_cast({:click, {:save, tidbit_uuid}}, scene) do
    IO.puts("SAVINGGG #{inspect(Map.keys(scene.assigns))}")
    # TODO here, we have a new description in the scene.assigns, we need to save it to the tidbit
    # do it as an action ()traceable, nice) or just do it here?? For now just do it!
    Memelex.My.Wiki.get!(%{uuid: tidbit_uuid})
    |> Memelex.My.Wiki.update(%{data: scene.assigns.description_edit})

    {:noreply, scene}

    # I think the ultimate API for rendering the scene would be one where you define the scene like a LiveView, where you just define render/1 which takes in assigns, and then returns the graph. This is how I naturally end up doing it in my applications anyway, usually with a specific struct to be the "state" and I only end up using assigns, to assign a state, which I think is a departure from the original vision a little bit.
    # The thing that would make this super hard though is that, even now as I sort of code this way, I end up calling render for basically all changes to a scene, which can cause a lot of computational overhead as processes spin up / get destroyed - really what I want is to push changes down to those components & not re-render them, but there isn't an easy way to do that inside my other design choice which is to have a render function which is pure & has no side effects
    # I believe there was a ton of work put into React so that it worked this way, where it calculates the smallest changes it can make to the DOM based on your state changes and only updating those, rather than re-drawing all the time, to make it performant. I wonder how feasible it would be to have Scenic work the same way :thinking_face:
    # image.png

    # Flamelex.Fluxus.action({__MODULE__, {:edit_todo, tidbit_uuid}})
    # {:noreply, scene |> assign(edit_description?: false)}
    # ^^ in my imagination this code would automatically cause an efficient update to my scene, without "re-rendering" in the sense of creating a new Scenic component process
  end

  # def handle_info(
  #       {:radix_state_change, %{apps: %{todo_details: %State{} = state}}},
  #       %{assigns: %{frame: f, state: state}} = scene
  #     ) do
  #   # state variables in pattern match are the same, therefore no state change occured
  #   {:noreply, scene}
  # end

  def handle_info(
        {:radix_state_change, %{apps: %{todo_details: %TODOdetails.State{} = new_state}}},
        %{assigns: %{frame: f, state: old_state}} = scene
      ) do
    # if new_state.tidbit == old_state.tidbit do
    #   # tidbit didbn't change, do nothing...
    #   IO.puts("GOT MSG BUT SAME OLD TIDBIT!")
    #   {:noreply, scene}
    # else
    # reset the scroll if we change the TidBit
    new_state = %{new_state | scroll: {0, 0}}
    {:ok, new_graph} = TODOdetails.Renderizer.render(f, new_state)

    new_scene =
      scene
      |> assign(graph: new_graph)
      |> assign(state: new_state)
      |> push_graph(new_graph)

    {:noreply, new_scene}
  end

  def handle_event({:click, :higher_priority}, _from, scene) do
    scene.assigns.state
    |> Memelex.My.Wiki.update(%{priority: :higher})

    {:noreply, scene}
  end

  def handle_event({:click, :close}, _from, scene) do
    Flamelex.Fluxus.action({[app: __MODULE__], :close_todo})
    {:noreply, scene}
  end

  def handle_event({:click, btn}, _from, scene) do
    IO.puts("Sample button was clicked in HANDLE EVENT! #{inspect(btn)}")
    {:noreply, scene}
  end

  def handle_event({:value_changed, {:data, _tidbit_uuid}, new_text}, _from, scene) do
    # Flamelex.Fluxus.action({__MODULE__, {:edit_todo, tidbit_uuid, new_text}})
    IO.puts("VAL CHANGED")
    {:noreply, scene |> assign(description_edit: new_text)}
  end
end
