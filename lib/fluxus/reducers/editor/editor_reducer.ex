defmodule Flamelex.Fluxus.Reducers.Editor do
  @moduledoc false
  use Flamelex.Lib.ProjectAliases
  require Logger

  def process(radix_state, :split_layer_one) do
    old_layout = radix_state.root.layers.one.layout
    new_layout = Map.merge(old_layout, %{editor: :split})

    new_radix_state =
      radix_state
      |> put_in([:root, :layers, :one, :layout], new_layout)

    {:ok, new_radix_state}
  end

  # def process(radix_state, :open_hexdocs) do
  #   new_radix_state =
  #     radix_state
  #     |> put_in([:root, :active_app], :hexdocs)

  #   {:ok, new_radix_state}
  # end

  def process(radix_state, :show_explorer) do
    old_layout = radix_state.root.layers.one.layout
    new_layout = Map.merge(old_layout, %{explorer: %{active?: true}})

    new_radix_state =
      radix_state
      |> put_in([:root, :layers, :one, :layout], new_layout)

    {:ok, new_radix_state}
  end

  def process(radix_state, :hide_explorer) do
    old_layout = radix_state.root.layers.one.layout
    new_layout = Map.merge(old_layout, %{explorer: %{active?: false}})

    new_radix_state =
      radix_state
      |> put_in([:root, :layers, :one, :layout], new_layout)

    {:ok, new_radix_state}
  end
end
