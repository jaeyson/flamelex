defmodule Flamelex.GUI.Components.Renseijin do
  @moduledoc """
  In order to begin an alchemical transmutation, a symbol called a
  Transmutation Circle (錬成陣, Renseijin) is necessary. A Transmutation
  Circle can either be drawn on the spot when a transmutation is necessary
  (in chalk, pencil, ink, paint, thread, blood or even traced in dirt) or
  permanently etched or inscribed beforehand, but without it, transmutation
  is generally impossible.

  All Transmutation Circles are made up of two parts:

     1)  The circle itself is a conduit which focuses and dictates the
        flow of power, tapping into the energies that already exist
        within the earth and matter. It represents the cyclical flow of
        the world's energies and phenomena and turns that power to
        manipulable ends.

     2) Inside the circle are specific alchemical runes. These runes vary
        widely based on ancient alchemical studies, texts, and experimentation,
        but correspond to a different form of energy, allowing the energy
        that is focused within the circle to be released in the way most
        conducive to the alchemist's desired effect. In basic alchemy, these
        runes will often take the form of triangles (which, when positioned
        differently, can represent the elements of either water, earth,
        fire or air), but will often be composed of varying polygons built
        from different triangles. For example, the hexagram is a commonly
        used base rune in Transmutation Circles because it creates eight
        multi-directional triangles when inscribed and can, therefore,
        represent all four classical elements at once. Other, more esoteric
        runes (including astrological symbols, symbolic images and varying
        lines of text) are prevalent and represent a multitude of other,
        specific functions for the alchemical energy that is released.

  - https://fma.fandom.com/wiki/Alchemy
  """
  use Scenic.Component
  alias Flamelex.GUI.Components.Renseijin
  # alias Flamelex.GUI.Components.Renseijin.{State, Utils}
  alias Widgex.Frame
  require Logger

  @starting_rotation Renseijin.State.starting_rotation()

  def validate(%{frame: %Widgex.Frame{} = _f} = data) do
    {:ok, data}
  end

  def init(
        %Scenic.Scene{} = scene,
        %{frame: %Widgex.Frame{} = frame},
        opts
      ) do
    Logger.debug("#{__MODULE__} initializing...")

    # TODO fetch the theme coming in from the opts, and use it to set the primary_color
    state = Renseijin.State.new()

    new_graph = render(frame, state)

    new_scene =
      scene
      |> assign(graph: new_graph)
      |> assign(frame: frame)
      |> assign(state: state)
      |> push_graph(new_graph)

    # run a separate timer for the changing colours in the taijitu tails
    {:ok, _timer} = :timer.send_interval(15, :taijitu_tick)

    request_input(new_scene, [:cursor_pos])

    {:ok, new_scene}
  end

  def handle_cast(
        :start_animation,
        %{assigns: %{state: %Renseijin.State{animate?: true}}} = scene
      ) do
    # Logger.debug(
    #   "#{__MODULE__} received msg: :start_animation, but ignoring it because we're already animated..."
    # )

    {:noreply, scene}
  end

  def handle_cast(
        :start_animation,
        %{assigns: %{state: %Renseijin.State{timer: nil} = state}} = scene
      ) do
    Logger.debug("#{__MODULE__} received msg: :start_animation")

    # A note on a most amusing bug
    #
    # While trying to implement a hover functionality on the Renseijin, I
    # wanted to make it tramsmote whenever we hovered over the center. So,
    # I set it up to call 'transmote begin" whenever it detected that happen -
    # the GUI component would call this function
    #
    # At the time, before we had the guard above, this would just immediately
    # call this handle_cast, which would immediately start a NEW timer -
    # effectively doubling the clock speed of the animation!
    #
    # At first I thought this was quite a cool effect - I overcoupled it
    # to something else, which was how fast I was moving my mouse, and I
    # thought I had somehow introduced a pseudo-random element to how fast
    # the animation would occur, based on moving the mouse in and out - and
    # I experimented with this for a while - it seemed that as we moved in,
    # it got faster & faster, until it started to slow again (presumably when
    # I pulled the mouse away), and then it sort of just stayed slow no matter
    # what I could do... eventually I realised that I was first flooding
    # the process with timer messages (thus increasing animation speed) up
    # until a point, whereupon the animation began to SLOW again, probably
    # because it had a big backlock of messages!

    # Evaluates Destination ! Message repeatedly after Time milliseconds
    {:ok, timer} = :timer.send_interval(scene.assigns.state.animation_rate, :tick)

    new_state = Renseijin.State.cast(state, %{animate?: true, timer: timer})

    {:noreply, scene |> assign(state: new_state)}
  end

  def handle_cast(
        :stop_animation,
        %{assigns: %{state: %Renseijin.State{animate?: true, timer: timer} = state}} = scene
      ) do
    Logger.debug("#{__MODULE__} received msg: :stop_animation")

    :timer.cancel(timer)

    new_state =
      Renseijin.State.cast(state, %{
        animate?: false,
        timer: nil
      })

    {:noreply, scene |> assign(state: new_state)}
  end

  def handle_cast(:stop_animation, scene) do
    Logger.debug("#{__MODULE__} received msg: :stop_animation, ignoring it completely...")
    {:noreply, scene}
  end

  # def handle_cast(:reset_animation, %{assigns: %{state: %State{} = state}} = scene) do
  def handle_cast(:reset_animation, %{assigns: %{state: state}} = scene) do
    Logger.debug("#{__MODULE__} received msg: :reset_animation...")

    new_state =
      Renseijin.State.cast(state, %{
        rotation: @starting_rotation
      })

    handle_render(scene, new_state)
  end

  def handle_cast({:redraw, %Renseijin.State{} = new_state}, scene) do
    handle_render(scene, new_state)
  end

  def handle_info(:tick, %{assigns: %{state: %Renseijin.State{rotation: r} = state}} = scene)
      when r < 0 or r > 360 do
    # reset the rotation, we've gone full-circle

    new_state =
      Renseijin.State.cast(state, %{
        rotation: @starting_rotation
      })

    handle_render(scene, new_state)
  end

  def handle_info(:tick, %{assigns: %{state: %Renseijin.State{rotation: r} = state}} = scene)
      when r >= 0 and r <= 360 do
    # Logger.debug("#{__MODULE__} received: :tick")

    new_state = Renseijin.State.cast(state, :tick)

    # TODO don't re-render the whole scene here :( this is tragic!!
    handle_render(scene, new_state)
  end

  # def handle_info(:taijitu_tick, scene) do
  #   {:noreply, scene}
  # end

  def handle_info(:taijitu_tick, %{assigns: assigns} = scene) do
    %{state: state, graph: graph} = assigns

    new_color_index = rem(state.taijitu.color_index + 1, length(state.taijitu.rainbow))
    new_stroke_color = Enum.at(state.taijitu.rainbow, new_color_index)

    updated_graph =
      graph
      |> Scenic.Graph.modify(
        :taijitu_tail,
        &Scenic.Primitives.update_opts(&1, stroke: {state.taijitu.stroke_width, new_stroke_color})
      )

    # |> Graph.modify(
    #   :taijitu_tail_2,
    #   &update_opts(&1, stroke: {state.taijitu.stroke.width, stroke_color})
    # )

    t = state.taijitu

    new_t = %{
      t
      | color_index: new_color_index
    }

    # new_state = %{state | color_index: new_color_index}
    new_state = %{state | taijitu: new_t}

    {:noreply,
     scene
     |> assign(state: new_state, graph: updated_graph)
     |> push_graph(updated_graph)}
  end

  def handle_input({:cursor_pos, {x, y}}, _context, scene) do
    centerpoint = Frame.center(scene.assigns.frame)
    # Logger.debug "#{__MODULE__} handling cursor_pos - centerpoint: #{inspect centerpoint}"
    if {x, y} |> Renseijin.Utils.within_box?(centerpoint, scene.assigns.state.cool_kid_radius) do
      GenServer.cast(self(), :start_animation)
      {:noreply, scene}
    else
      # Logger.debug "#{__MODULE__} detected cursor_pos `#{inspect {x, y}}`, and classified it as: outside the inner radius"
      if scene.assigns.state.animate?, do: GenServer.cast(self(), :stop_animation)
      {:noreply, scene}
    end
  end

  @doc """
  The unique function which renders the Renseijin component.
  """
  @spec render(Widgex.Frame.t(), Renseijin.State.t()) :: Scenic.Graph.t()
  def render(%Widgex.Frame{} = frame, %Renseijin.State{} = state) do
    Scenic.Graph.build()
    |> Renseijin.Utils.draw_background(frame, state)
    |> Scenic.Primitives.group(
      fn graph ->
        graph
        |> Renseijin.Utils.draw_circles(frame, state)
        |> Renseijin.Utils.draw_triangles(frame, state)
        |> Renseijin.Utils.draw_taijitu(frame, state)
        |> Renseijin.Utils.draw_hexagons(frame, state)

        # |> Utils.draw_squares(frame, state)
        # |> Utils.draw_pyramids(frame, state)
      end,
      id: __MODULE__,
      translate: Frame.center(frame).point
    )
    |> Scenic.Graph.modify(:scissor, frame.size.box)
  end

  # a way of re-using a code-pattern inside this module, nothing more
  defp handle_render(%Scenic.Scene{} = scene, %Renseijin.State{} = new_state) do
    new_graph = render(scene.assigns.frame, new_state)

    new_scene =
      scene
      |> assign(state: new_state)
      |> assign(graph: new_graph)
      |> push_graph(new_graph)

    {:noreply, new_scene}
  end
end
