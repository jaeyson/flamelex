defmodule Flamelex.GUI.Component.QlxWrap.Mutator do

  def add_open_buffer(rdx, %Quillex.Structs.BufState.BufRef{} = buf_ref) do
    rdx
    |> put_in([:apps, :qlx_wrap, :buffers], rdx.apps.qlx_wrap.buffers ++ [buf_ref])
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

    if rdx.apps.qlx_wrap.active_buf.uuid == buf_uuid do
      IO.puts "O)WHFO*IHWFOWIHFWOEIHFEWOIHFEWF"
      rdx
      |> put_in([:apps, :qlx_wrap, :active_buf], %{rdx.apps.qlx_wrap.active_buf|mode: mode})
      |> put_in([:apps, :qlx_wrap, :buffers], updated_bufs)
    else
      IO.puts "-------------------333"
      rdx
      |> put_in([:apps, :qlx_wrap, :buffers], updated_bufs)
    end
  end

  def set_active_buf(rdx, %Quillex.Structs.BufState.BufRef{} = buf_ref) do
    case rdx.apps.qlx_wrap.buffers
         |> Enum.find_index(&(&1.uuid == buf_ref.uuid)) do
      nil ->
        raise "Can not set active buffer to a buffer that doesn't exist"

      b_num when is_integer(b_num) ->
        rdx
        |> put_in([:apps, :qlx_wrap, :active_buf], buf_ref)
    end
  end

  # this doesnt do the actual save, but it mutates the radix state to show that a save took place / triggers updates required now that we've saved something
  def save_buffer(rdx, %{name: _unnamed, uuid: buf_uuid} = buf_ref, %{source: %{filepath: file_path}}) do
    # look at where this buf ref is used
    # dbg()
    updated_bufs =
      Enum.map(rdx.apps.qlx_wrap.buffers, fn
        %{uuid: ^buf_uuid} = buf ->
          # %{buf | mode: mode}
          {:ok, buf} = Quillex.Buffer.Process.fetch_buf(buf_ref)

          # regenerate a new buf_ref so that we have the most up to date version
          Quillex.Structs.BufState.BufRef.generate(buf)

        buf_ref ->
          buf_ref
      end)

    if rdx.apps.qlx_wrap.active_buf.uuid == buf_uuid do
      # regenerate a new buf_ref so that we have the most up to date version
      {:ok, buf} = Quillex.Buffer.Process.fetch_buf(buf_ref)
      active_buf = Quillex.Structs.BufState.BufRef.generate(buf)

      rdx
      |> put_in([:apps, :qlx_wrap, :active_buf], active_buf)
      |> put_in([:apps, :qlx_wrap, :buffers], updated_bufs)
    else
      rdx
      |> put_in([:apps, :qlx_wrap, :buffers], updated_bufs)
    end
  end

  def cancel_modal(%{apps: %{qlx_wrap: %{req_save: %{do?: true}}}} = rdx) do
    rdx
    |> put_in([:apps, :qlx_wrap, :req_save], %{do?: false, data: nil})
  end

  def cancel_modal(rdx) do
    IO.puts ";0 :0 ;)"
    rdx
    |> put_in([:apps, :qlx_wrap, :req_save], %{do?: false, data: nil})
  end

  def set_layout(rdx, new_layout) do
    rdx
    |> put_in([:apps, :qlx_wrap, :layout], new_layout)
  end

  def request_save_for_buffer(
        %{apps: %{qlx_wrap: %{req_save: %{do?: false, data: nil}}}} = rdx,
        buf_ref
      ) do
    rdx
    |> put_in([:apps, :qlx_wrap, :req_save], %{do?: true, buf: buf_ref, data: nil})
  end
end
