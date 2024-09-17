defmodule Flamelex.Fluxus.TODOsUserInputHandler do
  require Logger
  use ScenicWidgets.ScenicEventsDefinitions
  alias Flamelex.Fluxus.Layer01Mutators

  def process(
        %{
          layers: %{
            one: %{
              active_apps: [
                {Flamelex.GUI.Component.TODOlist, _args1},
                {Flamelex.GUI.Component.TODOdetails, _args2}
              ]
            }
          }
        },
        @space_bar
      ) do
    # Logger.warn("ignoring input: #{inspect(input)}")
    IO.puts("GOT SPACE")
    :ignore
  end

  def process(
        %{
          layers: %{
            one: %{
              layout: :split_screen,
              active_apps: [
                {Flamelex.GUI.Component.TODOlist, todos},
                {Flamelex.GUI.Component.TODOdetails, _args2}
              ]
            }
          }
        } = rdx,
        @escape_key
      ) do
    rdx
    |> put_in([:layers, :one, :layout], :full_screen)
    |> put_in(
      [:layers, :one, :active_apps],
      [{Flamelex.GUI.Component.TODOlist, todos}]
    )
  end

  def process(rdx, input) do
    Logger.warn("#{__MODULE__} ignoring input: #{inspect(input)}")
    :ignore
  end
end
