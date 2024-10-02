defmodule Flamelex.API.Renseijin do
  @moduledoc """
  “Give me today, for once, the worst throw of your dice, destiny.
  Today I transmute everything into gold.”

  — Friedrich Nietzsche
  """
  alias Flamelex.GUI.Component.Renseijin

  def reset_animation do
    GenServer.cast(Renseijin, :reset_animation)
  end

  def start_animation do
    # NOTE - this is one of the few components which we go around the
    # Fluxus system, and just send it messages directly, because it is
    # unaffected by any other state in the application.
    IO.puts("~~ Double, double toil and trouble; Fire burn and cauldron bubble ~~")

    GenServer.cast(Renseijin, :start_animation)
  end

  def stop_animation do
    GenServer.cast(Renseijin, :stop_animation)
  end

  # def kaomoji do
  #   "☆*:.｡.o(≧▽≦)o.｡.:*☆"
  # end
end
