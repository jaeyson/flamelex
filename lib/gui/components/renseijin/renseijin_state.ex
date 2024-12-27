defmodule Flamelex.GUI.Components.Renseijin.State do
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
  alias Widgex.Frame
  alias Flamelex.GUI.Components.Renseijin.State.RainbowColors

  @type t :: %__MODULE__{
          # coefficients of the equation which determine the radius of the inner circle
          inner_radius: %{
            scale: float(),
            offset_size: float()
          },
          # coefficients of the equation which determine the radius of the outer circle
          outer_radius: %{
            scale: float(),
            offset_size: float()
          },
          # variable to keep track of rotation during the animation
          rotation: float(),
          # field to hold a timer, which periodically sends us `tick`
          timer: term(),
          # the main color used to draw lines
          primary_color: atom(),
          # the stroke-width used to draw lines
          primary_stroke: integer(),
          # the color used to draw the relief lines
          relief_stroke: {integer(), atom()},
          # how many milliseseconds between ticks
          animation_rate: integer(),

          # how large of a circle to trigger an interaction
          cool_kid_radius: integer(),
          # circle_size: integer(),

          # how much to rotate the animation by on each tick
          tick_rotation: float(),

          # whether or not to show the Renseijin
          visible?: boolean(),

          # enable/disable the animation
          animate?: boolean()
        }

  # don't start at 0, the ying/yang looks vertical, it's cooler to
  # make it same as the hexagon (verticies meet)
  @starting_rotation 30

  defstruct inner_radius: %{
              scale: 0.97,
              offset_size: 17
            },
            outer_radius: %{
              scale: 1.07,
              offset_size: 12
            },
            taijitu: %{
              stroke: {2, :yellow},
              rainbow: RainbowColors.colors(),
              color_index: 0,
              stroke_width: 2
            },
            rotation: @starting_rotation,
            # animate?: false,
            timer: nil,
            primary_stroke: 2,
            # primary_color: :dark_violet,
            primary_color: {:color_rgba, {148, 0, 211, 97}},
            relief_stroke: {1, :grey},
            animation_rate: 17,
            cool_kid_radius: 80,
            tick_rotation: 0.72,
            visible?: true,
            animate?: false

  # The component is scaled relative to the width of the frame, we can
  # adjust this scale factor to make the component relatively larger or smaller
  @scale_factor 0.19

  # @spec cast(map()) :: t()

  def new do
    %__MODULE__{
      animate?: true
    }
  end

  def starting_rotation, do: @starting_rotation

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
        }
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

  def cast(%{
        # TODO radix state type here
        desktop: %{
          renseijin: %{
            animate?: animate?
          }
        }
      }) do
    %__MODULE__{
      animate?: animate?
    }
  end

  def radius(%Frame{} = frame) do
    frame.size.width / 2 * @scale_factor
  end

  def inner_radius(%Frame{} = frame, %__MODULE__{
        inner_radius: %{
          scale: scale,
          offset_size: offset_size
        }
      }) do
    scale * radius(frame) + offset_size
  end

  def outer_radius(%Frame{} = frame, %__MODULE__{
        outer_radius: %{
          scale: scale,
          offset_size: offset_size
        }
      }) do
    scale * radius(frame) + offset_size
  end
end
