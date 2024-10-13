defmodule Flamelex.GUI.Component.QlxWrap.Mutator do
  def add_open_buffer(rdx, buf_ref) do
    rdx
    |> put_in([:apps, :qlx_wrap, :buffers], [buf_ref] ++ rdx.apps.qlx_wrap.buffers)
  end

  def set_active_buf(rdx, %Quillex.Structs.Buffer.BufRef{} = buf_ref) do
    case rdx.apps.qlx_wrap.buffers
         |> Enum.find_index(&(&1.uuid == buf_ref.uuid)) do
      nil ->
        raise "Can not set active buffer to a buffer that doesn't exist"

      b_num when is_integer(b_num) ->
        # TODO in the future we will have a more sophisticated way
        # of tracking the open buffers...
        {new_active_buf, remaining_bufs} = List.pop_at(rdx.apps.qlx_wrap.buffers, b_num)

        rdx
        |> put_in(
          [:apps, :qlx_wrap, :buffers],
          [new_active_buf] ++ remaining_bufs
        )
    end
  end
end
