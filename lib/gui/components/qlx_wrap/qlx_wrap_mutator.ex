defmodule Flamelex.GUI.Component.QlxWrap.Mutator do
  def add_open_buffer(rdx, buf_ref) do
    rdx
    |> put_in([:apps, :qlx_wrap, :buffers], [buf_ref] ++ rdx.apps.qlx_wrap.buffers)
  end

  # TODO should probably have guards here for valid mode
  def set_buf_mode(rdx, %{uuid: buf_uuid} = buf_ref, mode) do
    updated_bufs =
      Enum.map(rdx.apps.qlx_wrap.buffers, fn
        %{uuid: ^buf_uuid} = buf ->
          %{buf | mode: mode}

        buf ->
          buf
      end)

    rdx
    |> put_in([:apps, :qlx_wrap, :buffers], updated_bufs)
  end

  def set_active_buf(rdx, %Quillex.Structs.BufState.BufRef{} = buf_ref) do
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

  def request_save_for_buffer(
        %{apps: %{qlx_wrap: %{req_save: %{do?: false, data: nil}}}} = rdx,
        buf_ref
      ) do
    rdx
    |> put_in([:apps, :qlx_wrap, :req_save], %{do?: true, buf: buf_ref, data: nil})
  end
end
