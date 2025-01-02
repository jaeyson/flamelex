defmodule Flamelex.GUI.Component.Kommander do
  use Scenic.Component
  alias Flamelex.GUI.Component.Kommander
  require Logger

  def validate(%{frame: %Widgex.Frame{} = _f} = data) do
    # Logger.debug "#{__MODULE__} accepted params: #{inspect data}"
    {:ok, data}
  end

  # args = %Widgex.Structs.LayerCake{}
  def init(scene, %{frame: %Widgex.Frame{} = frame}, opts) do

    init_state = Flamelex.Fluxus.RadixStore.get().apps.kommander
    init_graph = Kommander.Render.render(Scenic.Graph.build(), scene, frame, init_state)

    init_scene =
      scene
      |> assign(state: init_state)
      |> assign(frame: frame)
      |> assign(graph: init_graph)
      |> push_graph(init_graph)

    Flamelex.Lib.Utils.PubSub.subscribe(topic: :radix_state_change)

    {:ok, init_scene}
  end


  # these are actions which "bubble up" from the BufferPane
  def handle_cast(
    {Quillex.GUI.Components.BufferPane, :action, _buf_ref, [action]},
    scene
  ) when is_tuple(action) do
    Flamelex.Fluxus.action({Flamelex.GUI.Component.Kommander, action})
    {:noreply, scene}
  end

  def handle_info({:radix_state_change, %{apps: %{kommander: k_state}}}, %{assigns: %{state: k_state}} = scene) do
    {:noreply, scene}
  end

  def handle_info({:radix_state_change, %{apps: %{kommander: new_k_state}}}, %{assigns: %{state: k_state}} = scene) do
    IO.puts "GOT NEW K STSATE #{inspect k_state}"

    # {:ok, [pid]} = child(scene, {:text_pad, Kommander})
    # GenServer.cast(pid, {:redraw, k_buf})
    # {:noreply, scene |> assign(state: %{kommander_state | buffer: k_buf})}

    {:noreply, scene}
  end

  # def handle_cast({:scroll_limits, _new_scroll_state}, scene) do
  #   IO.puts("Kommander ignoring scroll limits update...")
  #   {:noreply, scene}
  # end

end
