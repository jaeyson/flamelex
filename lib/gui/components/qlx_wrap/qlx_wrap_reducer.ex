defmodule Flamelex.GUI.Component.QlxWrap.Reducer do
  # @moduledoc false

  alias Flamelex.Fluxus.RadixState
  alias Flamelex.GUI.Layers.Layer01.Mutator, as: Layer1
  alias Flamelex.GUI.Component.QlxWrap

  def process(
        %RadixState{} = rdx,
        :new_buffer
      ) do
    {:ok, buf_ref} = Quillex.Buffer.new()

    rdx
    |> Layer1.set_layout(:full_screen)
    |> Layer1.set_active_apps([QlxWrap])
    |> QlxWrap.Mutator.add_open_buffer(buf_ref)
    |> QlxWrap.Mutator.set_active_buf(buf_ref)
  end

  # @directions [:up, :down, :left, :right]
  # def process(
  #       %Editor.State{} = state,
  #       {:move_cursor, direction, x}
  #     )
  #     when is_integer(x) and x > 0 and direction in @directions do
  #   IO.puts("ALSO HITTING REDUCER")
  #   # state
  #   # |> Editor.Mutator.move_cursor({direction, x})
  #   # Flamelex.Lib.Utils.PubSub.broadcast(
  #   #   topic: {:buffers, hd(state.buffers).uuid},
  #   #   msg: {:move_cursor, direction, x}
  #   # )

  #   Quillex.Buffer.BufferManager.cast_to_buffer(
  #     hd(state.buffers).uuid,
  #     {:move_cursor, direction, x}
  #   )

  #   :re_routed
  # end

  # @directions [:up, :down, :left, :right]
  # def process(
  #       rdx,
  #       {:move_cursor, direction, x}
  #     )
  #     when is_integer(x) and x > 0 and direction in @directions do
  #   IO.puts()

  #   rdx
  #   |> Editor.Mutator.move_cursor({direction, x})
  # end

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

# # defmodule Flamelex.Fluxus.Reducers.Editor do
# defmodule Flamelex.GUI.Component.Editor.Reducer do
#   # @moduledoc false
#   # use Flamelex.Lib.ProjectAliases
#   # require Logger
#   alias Flamelex.Fluxus.RadixState
#   # alias Flamelex.GUI.Component.Editor
#   alias Flamelex.GUI.Layers.Layer01.Mutator, as: Layer1

#   def process(
#         # %RadixState{layers: %{one: %{active_apps: []}}} = rdx,
#         rdx,
#         :new_buffer
#       ) do
#     # {new_rdx, new_buf} = Editor.Mutator.add_buffer(rdx, %{"name" => "New Buffer"})

#     # new_rdx
#     #
#     #
#     # |> Editor.Mutator.set_active_buf("New Buffer")
#     rdx
#     |> Layer1.set_layout(:full_screen)
#     |> Layer1.set_active_apps([Editor])
#     |> Editor.Mutator.new_buffer(%{"name" => "New Buffer"})
#   end

#   # @directions [:up, :down, :left, :right]
#   # def process(
#   #       %Editor.State{} = state,
#   #       {:move_cursor, direction, x}
#   #     )
#   #     when is_integer(x) and x > 0 and direction in @directions do
#   #   IO.puts("ALSO HITTING REDUCER")
#   #   # state
#   #   # |> Editor.Mutator.move_cursor({direction, x})
#   #   # Flamelex.Lib.Utils.PubSub.broadcast(
#   #   #   topic: {:buffers, hd(state.buffers).uuid},
#   #   #   msg: {:move_cursor, direction, x}
#   #   # )

#   #   Quillex.Buffer.BufferManager.cast_to_buffer(
#   #     hd(state.buffers).uuid,
#   #     {:move_cursor, direction, x}
#   #   )

#   #   :re_routed
#   # end

#   # @directions [:up, :down, :left, :right]
#   # def process(
#   #       rdx,
#   #       {:move_cursor, direction, x}
#   #     )
#   #     when is_integer(x) and x > 0 and direction in @directions do
#   #   IO.puts()

#   #   rdx
#   #   |> Editor.Mutator.move_cursor({direction, x})
#   # end

#   #   # IO.puts("HERE WE NEED TO ADD A NEW BUFFER")
#   #   {new_rdx, new_buf} = Editor.Mutator.add_buffer(rdx, %{name: "New Buffer"})

#   #   new_rdx
#   #   |> Editor.Mutator.set_active_buf(new_buf)

#   # def process(radix_state, :split_layer_one) do
#   #   old_layout = radix_state.root.layers.one.layout
#   #   new_layout = Map.merge(old_layout, %{editor: :split})

#   #   new_radix_state =
#   #     radix_state
#   #     |> put_in([:root, :layers, :one, :layout], new_layout)

#   #   {:ok, new_radix_state}
#   # end

#   # # def process(radix_state, :open_hexdocs) do
#   # #   new_radix_state =
#   # #     radix_state
#   # #     |> put_in([:root, :active_app], :hexdocs)

#   # #   {:ok, new_radix_state}
#   # # end

#   # def process(radix_state, :show_explorer) do
#   #   old_layout = radix_state.root.layers.one.layout
#   #   new_layout = Map.merge(old_layout, %{explorer: %{active?: true}})

#   #   new_radix_state =
#   #     radix_state
#   #     |> put_in([:root, :layers, :one, :layout], new_layout)

#   #   {:ok, new_radix_state}
#   # end

#   # def process(radix_state, :hide_explorer) do
#   #   old_layout = radix_state.root.layers.one.layout
#   #   new_layout = Map.merge(old_layout, %{explorer: %{active?: false}})

#   #   new_radix_state =
#   #     radix_state
#   #     |> put_in([:root, :layers, :one, :layout], new_layout)

#   #   {:ok, new_radix_state}
#   # end
# end
