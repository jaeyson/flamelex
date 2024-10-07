defmodule Flamelex.GUI.Component.Editor.Mutator do
  @moduledoc """
  Functions to mutate the Radix state for the Editor component.
  """

  alias Flamelex.Fluxus.RadixState
  alias Flamelex.GUI.Component.Editor

  def new_buffer(%RadixState{} = rdx, args) do
    case Quillex.Buffer.new(args) do
      {:ok, %Quillex.Structs.Buffer.BufRef{} = buf_ref} ->
        # we still need to keep a reference to the buffer in our radix state,
        # so we can route input & events to it
        rdx
        |> put_in([:apps, :editor, :buffers], [buf_ref] ++ rdx.apps.editor.buffers)
        |> set_active_buf(buf_ref)

      {:error, _reason} ->
        raise "Failed to create new buffer"
    end
  end

  # def add_buffer(rdx, %{"name" => _new_buf} = args) do
  #   # TODO maybe make Buffer a real struct?

  #   # TODO here we would call QuillEx to create a new buffer

  #   # todo get pid / regtistered name of quill process
  #   # new_buf = %{
  #   #   uuid: UUID.uuid4(),
  #   #   name: new_buf
  #   # }

  #   case Quillex.Buffer.new(args) do
  #     {:ok, %Quillex.Structs.Buffer.BufRef{} = buf_ref} ->
  #       # we still need to keep a reference to the buffer in our radix state,
  #       # so we can route input & events to it
  #       new_rdx =
  #         rdx
  #         |> put_in([:apps, :editor, :buffers], rdx.apps.editor.buffers ++ [buf_ref])

  #       {new_rdx, buf_ref}

  #     {:error, _reason} ->
  #       raise "Failed to create new buffer"
  #   end
  # end

  # def move_cursor(%Editor.State{}, {direction, x}) do
  #   # TODO this is a placeholder, we need to actually move the cursor
  #   # cast_
  #   :re_routed
  # end

  # TODO for now active buf is just first in the list lol, ssurely this is not performant somehow
  def set_active_buf(rdx, %Quillex.Structs.Buffer.BufRef{name: new_buf}) do
    case rdx.apps.editor.buffers
         # TODO names is hacky cause ehtyre not unique!!
         |> Enum.find_index(fn buf -> buf.name == new_buf end) do
      nil ->
        raise "Can not set active buffer to a buffer that doesn't exist"

      b_num when is_integer(b_num) ->
        # TODO in the future we will have a more sophisticated way
        # of tracking the open buffers...
        {new_active_buf, remaining_bufs} = List.pop_at(rdx.apps.editor.buffers, b_num)

        rdx
        |> put_in(
          [:apps, :editor, :buffers],
          [new_active_buf] ++ remaining_bufs
        )
    end
  end

  # this is a bad function it assumes we only ever have one buffer open...
  # def move_cursor(rdx, {direction, x}) do
  #   # TODO this is a placeholder, we need to actually move the cursor
  #   IO.puts("RLY MOVE THE CURSOR")
  #   rdx
  # end
end
