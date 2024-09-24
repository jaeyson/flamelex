defmodule Flamelex.GUI.Component.TODOlist.UserInputHandler do
  require Logger
  use ScenicWidgets.ScenicEventsDefinitions
  alias Flamelex.GUI.Component.TODOlist

  def handle(rdx, @left_shift) do
    [{TODOlist.Reducer, {:set_turbo, true}}]
  end

  def handle(rdx, @left_shift_up) do
    [{TODOlist.Reducer, {:set_turbo, false}}]
  end

  @ignored_keys [
    @left_alt_dn,
    @left_alt_up
  ]
  def handle(rdx, input) when input in @ignored_keys do
    Logger.warn("#{__MODULE__} ignoring input: #{inspect(input)}")
    :ignore
  end

  # def process(
  #       %{
  #         layers: %{
  #           one: %{
  #             active_apps: [
  #               {Flamelex.GUI.Component.TODOlist, _args1},
  #               {Flamelex.GUI.Component.TODOdetails, _args2}
  #             ]
  #           }
  #         }
  #       },
  #       @space_bar
  #     ) do
  #   # Logger.warn("ignoring input: #{inspect(input)}")
  #   IO.puts("GOT SPACE")
  #   :ignore
  # end

  # def process(
  #       %{
  #         layers: %{
  #           one: %{
  #             layout: :split_screen,
  #             active_apps: [
  #               {Flamelex.GUI.Component.TODOlist, todos},
  #               {Flamelex.GUI.Component.TODOdetails, _args2}
  #             ]
  #           }
  #         }
  #       } = rdx,
  #       @escape_key
  #     ) do
  #   rdx
  #   |> put_in([:layers, :one, :layout], :full_screen)
  #   |> put_in(
  #     [:layers, :one, :active_apps],
  #     [{Flamelex.GUI.Component.TODOlist, todos}]
  #   )
  # end

  # def process(rdx_state, @left_shift) do
  #   rdx_state
  #   |> Layer01Mutators.set_turbo(true)
  # end

  # def process(rdx_state, @left_shift_up) do
  #   rdx_state
  #   |> Layer01Mutators.set_turbo(false)
  # end

  # TODO failing here should have no consequences but it does make a lot of noise so maybe we ignore bad input...

  # def process(rdx, input) do
  #   Logger.warn("#{__MODULE__} ignoring input: #{inspect(input)}")
  #   :ignore
  # end
end
