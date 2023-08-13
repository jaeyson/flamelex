defmodule Flamelex.GUI.Component.Renseijin.State do
  @moduledoc """
  Defines the internal state of a Renseijin.

  This struct holds various attributes that determine the current state of a Renseijin, including its rotation, animation status, and any related timer. Additionally, it includes various configuration settings such as primary color, animation rate, sizes, and mathematical constants.

  ## Fields

  - `rotation`: The current rotation angle of the Renseijin, as a float in degrees. Defaults to `0`.
  - `animate?`: A boolean that indicates whether the Renseijin is currently animating. Defaults to `false`.
  - `timer`: An optional reference to a timer that might be associated with the Renseijin, such as an animation timer. Defaults to `nil`.
  - `primary_color`: The primary color of the Renseijin. Defaults to `:dark_violet`.
  - `pi`: The value of π used in calculations. Defaults to `3.14159265359`.
  - `animation_rate`: The rate of animation in frames per second. Defaults to `10`.
  - `cool_kid_radius`: The radius of effect for special animations. Defaults to `80`.
  - `circle_size`: The size of the circle component. Defaults to `47`.
  """
  alias Widgex.Structs.Frame

  @real_pi 3.14159265359

  @type t :: %__MODULE__{
          rotation: float(),
          animate?: boolean(),
          timer: term(),
          primary_color: atom(),
          primary_stroke: 1,
          pi: float(),
          animation_rate: integer(),
          cool_kid_radius: integer(),
          circle_size: integer(),
          tick_rotation: float(),
          outer_rim: integer(),
          gap_size: integer()
        }

  defstruct rotation: 0,
            animate?: false,
            timer: nil,
            primary_color: :dark_violet,
            primary_stroke: 1,
            pi: @real_pi,
            animation_rate: 10,
            cool_kid_radius: 80,
            circle_size: 47,
            tick_rotation: 0.2,
            outer_rim: 20,
            gap_size: 4

  @spec new(map()) :: t()
  def new(%{
        animate?: animate?
      }) do
    %__MODULE__{
      animate?: animate?
    }
  end

  def cast(
        %__MODULE__{
          rotation: r,
          tick_rotation: tr
        } = state,
        :tick
      ) do
    # compute the change in %State{} for one :tick

    %{state | rotation: r + tr}
  end

  def cast(
        %__MODULE__{} = state,
        %{
          animate?: animate?,
          timer: timer
        } = state
      )
      when is_boolean(animate?) do
    %{
      state
      | animate?: animate?,
        timer: timer
    }
  end

  def cast(%__MODULE__{} = state, %{
        rotation: r
      })
      when r >= 0 and r <= 360 do
    %{state | rotation: r}
  end

  def circle_rad(%Frame{} = frame) do
    # we can get the scale_factor back this way!
    frame.size.width / 2 * 0.37
  end

  def inner_circle_radius(%Frame{} = frame, %__MODULE__{
        outer_rim: rim,
        gap_size: size
      }) do
    # outer_radius - rim + 2 * size + size/2
    circle_rad(frame) - rim + size
  end
end
