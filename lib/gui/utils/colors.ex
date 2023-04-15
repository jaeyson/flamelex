defmodule Flamelex.GUI.Colors do
  # TODO this should be a config
  def pallete do
    Flamelex.GUI.ColorsPalletes.Anakin
    # Flamelex.GUI.ColorsPalletes.Obiwan
  end

  def background do
    pallete().background()
  end

  def foreground do
    pallete().foreground()
  end

  def mode(:normal), do: :beige
  def mode(:insert), do: :green
  def mode(:kommand), do: :beige

  def menu_bar, do: :gray
end
