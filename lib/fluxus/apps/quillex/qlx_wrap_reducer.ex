defmodule Flamelex.GUI.Component.QlxWrap.Reducer do
  @moduledoc false
  alias Flamelex.Fluxus.RadixState
  alias Flamelex.GUI.Layers.Layer01
  alias Flamelex.GUI.Component.QlxWrap

  def process(
        %RadixState{} = rdx,
        :new_buffer
      ) do
    {:ok, buf_ref} = Quillex.Buffer.new()

    rdx
    |> Layer01.Mutator.set_layout(:full_screen)
    |> Layer01.Mutator.set_active_apps([QlxWrap])
    |> QlxWrap.Mutator.add_open_buffer(buf_ref)
    |> QlxWrap.Mutator.set_active_buf(buf_ref)
  end

  def process(
        %RadixState{} = rdx,
        :modal_cancel
      ) do
    rdx
    |> QlxWrap.Mutator.cancel_modal()
  end

  def process(
        %RadixState{} = rdx,
        {:save_buffer, filename}
      )
      when is_binary(filename) do
    # TODO in reality we need to marry this mnodalkk up to a buiffer, need to know if this is a new vs existing filename etc
    # but this will work for now and prove the plumbing is in place

    # TODO if we have a memex loaded, we could save this as in the memex, even instead of the filesystem !!

    {:ok, cwd} = File.cwd()

    buf = Flamelex.API.Buffer.active_buf(rdx)
    text = Enum.join(buf.data, "\n")

    File.write!("#{cwd}/#{filename}.txt", text)

    rdx
    |> QlxWrap.Mutator.cancel_modal()
  end

  def process(
        %RadixState{} = rdx,
        {:open_buffer, %{filepath: filepath}}
      ) do
    {:ok, buf_ref} = Quillex.Buffer.open(%{filepath: filepath})

    rdx
    |> Layer01.Mutator.set_layout(:full_screen)
    |> Layer01.Mutator.set_active_apps([QlxWrap])
    |> QlxWrap.Mutator.add_open_buffer(buf_ref)
    |> QlxWrap.Mutator.set_active_buf(buf_ref)
  end

  # def process(
  #       %RadixState{} = rdx,
  #       {:move_cursor, direction, x}
  #     ) do
  #   rdx
  # |> Layer01.Mutator.set_layout(:full_screen)
  # |> Layer01.Mutator.set_active_apps([QlxWrap])
  # |> QlxWrap.Mutator.add_open_buffer(buf_ref)
  # |> QlxWrap.Mutator.set_active_buf(buf_ref)
  # end

  def process(
        %RadixState{} = rdx,
        buf_ref,
        {:set_mode, m}
      ) do
    # TODO idea, maybe we could PUT EVENTS "UP" the component chain instead?

    # TODO this should just go to the GUI process, the buffer doesn't really have "modes"
    Quillex.Buffer.BufferManager.cast_to_buffer(
      buf_ref,
      {:action, {:set_mode, m}}
    )

    rdx
    |> QlxWrap.Mutator.set_buf_mode(buf_ref, m)

    # |> Layer01.Mutator.set_layout(:full_screen)
    # |> Layer01.Mutator.set_active_apps([QlxWrap])
    # |> QlxWrap.Mutator.add_open_buffer(buf_ref)
    # |> QlxWrap.Mutator.set_active_buf(buf_ref)
  end

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
        {:action, {:request_save, %{uuid: buf_uuid}}} = a
      ) do
    rdx
    |> QlxWrap.Mutator.request_save_for_buffer(buf_ref)
  end

  def process(
        %RadixState{} = rdx,
        # buf_ref,
        {:insert, _char, :at_cursor} = a
      ) do
    #TODO here, this is going to cause a fundamental problem
    IO.puts "HERE WE ARE GONNA TRY CASTING TO BUFFER & HAVE FLAMELEX LISTEN TO THE QLX EVENT BACK I GUESS"
    # if we re-use this reducer, then we need to
    # be able to call directly into it & return a modified radix-state (if we call this from flamelex that is)

    # this is where I think, we really ought to have the ability to *call* the buffer,
    # because the whole point of this function "process" is that it returns an updated radix state
    # now arguably I guess, we do ignore it on this level... but then the buffer really has to update & broadcast
    # the state change out to the gui (could be on a buffer specific channel I guess)
    # Quillex.Buffer.BufferManager.cast_to_buffer(buf_ref, a)

    buf_ref = rdx.apps.qlx_wrap.buffers |> hd() #TODO use a real active buffer functionality here
    # arguably this should be cast here, since it frees up the radix state, but honestly I want to lock it while we process this just to keep it sequential & simple
    Quillex.Buffer.BufferManager.call_buffer(buf_ref, {:action, a})

    # ignore on this level, buffer can update & broadcast out any changesk but no radix level changes will occur
    :ignore
  end

  def process(
        %RadixState{} = rdx,
        buf_ref,
        {:action, {:newline, :at_cursor}} = a
      ) do
    Quillex.Buffer.BufferManager.cast_to_buffer(buf_ref, a)
    :ignore
  end

  def process(
        %RadixState{} = rdx,
        buf_ref,
        {:action, {:delete, :before_cursor}} = a
      ) do
    Quillex.Buffer.BufferManager.cast_to_buffer(buf_ref, a)
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
  def process(rdx, unmatched_action) do
    IO.puts "ERERRERERERER - #{inspect unmatched_action}"
    rdx
  end
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
