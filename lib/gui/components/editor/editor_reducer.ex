# defmodule Flamelex.Fluxus.Reducers.Editor do
defmodule Flamelex.GUI.Component.Editor.Reducer do
  # @moduledoc false
  # use Flamelex.Lib.ProjectAliases
  # require Logger
  alias Flamelex.Fluxus.RadixState
  alias Flamelex.GUI.Component.Editor
  alias Flamelex.GUI.Layers.Layer01.Mutator, as: Layer1

  def process(
        # %RadixState{layers: %{one: %{active_apps: []}}} = rdx,
        rdx,
        :new_buffer
      ) do
    {new_rdx, new_buf} = Editor.Mutator.add_buffer(rdx, %{"name" => "New Buffer"})

    new_rdx
    |> Layer1.set_active_apps([Editor])
    |> Layer1.set_layout(:full_screen)
    |> Editor.Mutator.set_active_buf("New Buffer")
  end

  #   # IO.puts("HERE WE NEED TO ADD A NEW BUFFER")
  #   {new_rdx, new_buf} = Editor.Mutator.add_buffer(rdx, %{name: "New Buffer"})

  #   new_rdx
  #   |> Editor.Mutator.set_active_buf(new_buf)

  # def process(radix_state, :split_layer_one) do
  #   old_layout = radix_state.root.layers.one.layout
  #   new_layout = Map.merge(old_layout, %{editor: :split})

  #   new_radix_state =
  #     radix_state
  #     |> put_in([:root, :layers, :one, :layout], new_layout)

  #   {:ok, new_radix_state}
  # end

  # # def process(radix_state, :open_hexdocs) do
  # #   new_radix_state =
  # #     radix_state
  # #     |> put_in([:root, :active_app], :hexdocs)

  # #   {:ok, new_radix_state}
  # # end

  # def process(radix_state, :show_explorer) do
  #   old_layout = radix_state.root.layers.one.layout
  #   new_layout = Map.merge(old_layout, %{explorer: %{active?: true}})

  #   new_radix_state =
  #     radix_state
  #     |> put_in([:root, :layers, :one, :layout], new_layout)

  #   {:ok, new_radix_state}
  # end

  # def process(radix_state, :hide_explorer) do
  #   old_layout = radix_state.root.layers.one.layout
  #   new_layout = Map.merge(old_layout, %{explorer: %{active?: false}})

  #   new_radix_state =
  #     radix_state
  #     |> put_in([:root, :layers, :one, :layout], new_layout)

  #   {:ok, new_radix_state}
  # end
end
