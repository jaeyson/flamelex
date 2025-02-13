defmodule Memelex.GUI.Components.HyperCard do
  use Scenic.Component
  alias __MODULE__
  # alias Memelex.Fluxus.Reducers.RadixReducer
  # alias Memelex.Fluxus.Reducers.TidbitReducer
  # alias Flamelex.GUI.Component.RapidSelector.Reducer

  # TODO document this point
  # TODO good idea: render each sub-component as a seperate graph,
  #                calculate their heights, then use Scenic.Graph.add_to
  #                to put them into the `:hypercard_itself` group
  #                -> Unfortunately, this doesn't work because Scenic
  #                doesn't seem to support "merging" 2 graphs, or
  #                if I return a graph (each component), no way to
  #                simply add that to another graph, as a sub-component

  # REMINDER: Here we call back to the outer-component with out size, since
  # 		     HyperCards are flexible in size

  #TODo ok now we're here! EXCITING!!
  def validate(%{
    frame: %Widgex.Frame{} = frame,
    state: %Memelex.TidBit{} = state
  } = data) do
    {:ok, %{
      frame: frame,
      state: state
    }}
  end

  # accept drafts too
  def validate(%{
    frame: %Widgex.Frame{} = frame,
    state: {:draft, %Memelex.TidBit{}} = state
  } = data) do
    {:ok, %{
      frame: frame,
      state: state
    }}
  end

  def init(
    %Scenic.Scene{} = scene,
    %{
      frame: %Widgex.Frame{} = frame,
      state: state
    },
    opts
  ) do
    graph = HyperCard.Renderizer.render(Scenic.Graph.build(), scene, frame, state)

    init_scene =
      scene
      |> assign(graph: graph)
      |> assign(state: state)
      |> push_graph(graph)

    # Memelex.Utils.PubSub.subscribe()

    {:ok, init_scene}
  end

  # def handle_event({:value_changed, :title, new_title}, _context, {:draft, draft_state} = scene) do
    def handle_event({:value_changed, :title, new_title}, _context, %{assigns: %{state: {:draft, dft_tidbit}}} = scene) do
    # ignore it for now, the way this component work sit will keep track of it until we go to save (??)
    # {:draft, %Memelex.TidBit{title: d_title} = d_state} = scene.assigns.state

    IO.puts new_title
    # {:noreply, {:draft, %{draft_state|title: new_title}}}

    #TODO name the actual collection, call the TidBit Collection `whatever`
    {:noreply, scene |> assign(state: {:draft, %{dft_tidbit|title: new_title}})}
  end

  def handle_event(_e, _context, scene) do
    IO.inspect(scene.assigns.state)
    # ignore it for now, the way this component work sit will keep track of it until we go to save (??)
    {:noreply, scene}
  end

  def handle_cast({:click, :save_tidbit}, %{assigns: %{state: {:draft, dft_tidbit}}} = scene) do
    IO.puts "SAVING #{inspect dft_tidbit}"

    # here we would attempt to save, if it fails then show an error
    {:ok, saved_tidbit} = Memelex.My.Wiki.save(dft_tidbit) # this then in turn will eventually throw some kind of action back `tidbit_opened`

    {:noreply, scene |> assign(state: saved_tidbit)}
  end

  def handle_cast(msg, scene) do
    IO.puts "got msg #{inspect msg} #{inspect scene.assigns.state}"
    {:noreply, scene}
  end

end

  # 	def handle_continue(:publish_bounds, scene) do
  #         bounds = Scenic.Graph.bounds(scene.assigns.graph)

  # 		#TODO use cast to parent instead
  # 		# send_parent_event(scene, {:value_changed, scene.assigns.id, new_text})
  # 		Flamelex.GUI.Component.Memex.StoryRiver
  # 		|> GenServer.cast({:new_component_bounds, {scene.assigns.state.uuid, bounds}})

  #         {:noreply, scene, {:continue, :render_next_hyper_card}}
  #     end

  # 	def handle_continue(:render_next_hyper_card, scene) do
  # 		#TODO use cast to parent instead
  # 		# send_parent_event(scene, {:value_changed, scene.assigns.id, new_text})
  # 		Flamelex.GUI.Component.Memex.StoryRiver |> GenServer.cast(:render_next_component)
  # 		{:noreply, scene}
  # 	end

  # def handle_cast({:click, {:close, tidbit_uuid}}, scene) do
  #   # TODO pass it up to the story river (including tidbit info)
  #   # which will then in turn call the API to close it?? Or just keep doing it here??
  #   Flamelex.Fluxus.action({RapidSelector.Reducer, {:close_tidbit, %{tidbit_uuid: tidbit_uuid}}})
  #   {:noreply, scene}
  # end

  # def handle_cast({:click, {:edit, tidbit_uuid}}, scene) do
  #   IO.puts("SHOULD EDIT TIDBIT")
  #   # Memelex.Fluxus.action({TidbitReducer, {:set_gui_mode, :edit, %{tidbit_uuid: tidbit_uuid}}})
  #   {:noreply, scene}
  # end

  # def handle_cast({:click, {:save, tidbit_uuid}}, scene) do
  #   Memelex.Fluxus.action({TidbitReducer, {:save_tidbit, %{tidbit_uuid: tidbit_uuid}}})
  #   {:noreply, scene}
  # end

  # def handle_cast({:click, {:discard_changes, tidbit_uuid}}, scene) do
  #   Memelex.Fluxus.action({TidbitReducer, {:discard_changes, %{tidbit_uuid: tidbit_uuid}}})
  #   {:noreply, scene}
  # end

  # def handle_cast({:click, {:delete, tidbit_uuid}}, scene) do
  #   Memelex.Fluxus.action({TidbitReducer, {:delete_tidbit, %{tidbit_uuid: tidbit_uuid}}})
  #   {:noreply, scene}
  # end

  # def handle_event({:click, {:open_external_textfile, filepath}}, _from, scene) do
  #   IO.puts("Sample button was clicked! #{filepath}")
  #   Memelex.Utils.ToolBag.open_external_textfile(filepath)
  #   {:noreply, scene}
  # end

  # def handle_info({:radix_state_change, new_radix_state}, scene) do
  #   # TODO would be better if we caught spcific TidBit changes here, rather
  #   # than re-rendering the entire StoryRiver...
  #   {:noreply, scene}
  # end

  # def handle_info({:wiki_server, :memex_saved_to_disc}, scene) do
  #   # get child processes & cast update to SideNav
  #   {:noreply, scene}
  # end
