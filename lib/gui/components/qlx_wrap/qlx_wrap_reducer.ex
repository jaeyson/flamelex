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

  def process(
        %RadixState{} = rdx,
        {:open_buffer, %{filepath: filepath}}
      ) do
    {:ok, buf_ref} = Quillex.Buffer.open(%{filepath: filepath})

    rdx
    |> Layer1.set_layout(:full_screen)
    |> Layer1.set_active_apps([QlxWrap])
    |> QlxWrap.Mutator.add_open_buffer(buf_ref)
    |> QlxWrap.Mutator.set_active_buf(buf_ref)
  end

  # def process(
  #       %RadixState{} = rdx,
  #       {:move_cursor, direction, x}
  #     ) do
  #   rdx
  # |> Layer1.set_layout(:full_screen)
  # |> Layer1.set_active_apps([QlxWrap])
  # |> QlxWrap.Mutator.add_open_buffer(buf_ref)
  # |> QlxWrap.Mutator.set_active_buf(buf_ref)
  # end

  def process(
        %RadixState{} = rdx,
        buf_ref,
        {:set_mode, m}
      ) do
    # TODO idea, maybe we could PUT EVENTS "UP" the component chain instead?

    Quillex.Buffer.BufferManager.cast_to_buffer(
      buf_ref,
      {:action, {:set_mode, m}}
    )

    rdx
    |> QlxWrap.Mutator.set_buf_mode(buf_ref, m)

    # |> Layer1.set_layout(:full_screen)
    # |> Layer1.set_active_apps([QlxWrap])
    # |> QlxWrap.Mutator.add_open_buffer(buf_ref)
    # |> QlxWrap.Mutator.set_active_buf(buf_ref)
  end

  # def process(
  #       %RadixState{} = rdx,
  #       buf_ref,
  #       {:insert, text, :at_cursor}
  #     ) do
  #   Quillex.Buffer.BufferManager.cast_to_buffer(
  #     buf_ref,
  #     {:action, {:insert, text, :at_cursor}}
  #   )
  # end

  # def process(
  #       %RadixState{} = rdx,
  #       buf_ref,
  #       {:move_cursor, direction, x}
  #     ) do
  #   Quillex.Buffer.BufferManager.cast_to_buffer(
  #     buf_ref,
  #     {:action, {:move_cursor, direction, x}}
  #   )

  #   :ignore
  # end

  def process(
        %RadixState{} = rdx,
        buf_ref,
        actions
      ) do
    Quillex.Buffer.BufferManager.cast_to_buffer(
      buf_ref,
      actions
    )

    :ignore
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

  #   Quillex.Buffer.BufferManager.send_to_buffer(
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

#   #   Quillex.Buffer.BufferManager.send_to_buffer(
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
