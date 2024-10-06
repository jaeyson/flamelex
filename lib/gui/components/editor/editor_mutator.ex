defmodule Flamelex.GUI.Component.Editor.Mutator do
  @moduledoc """
  Functions to mutate the Radix state for the Editor component.
  """

  alias Flamelex.Fluxus.RadixState
  alias Flamelex.GUI.Component.Editor

  def add_buffer(rdx, %{"name" => new_buf}) do
    # TODO maybe make Buffer a real struct?
    new_buf = %{
      uuid: UUID.uuid4(),
      name: new_buf,
      content: ""
    }

    new_rdx =
      rdx
      |> put_in([:apps, :editor, :buffers], rdx.apps.editor.buffers ++ [new_buf])

    {new_rdx, new_buf}
  end

  # def move_cursor(%Editor.State{}, {direction, x}) do
  #   # TODO this is a placeholder, we need to actually move the cursor
  #   # cast_
  #   :re_routed
  # end

  # TODO for now active buf is just first in the list lol, ssurely this is not performant somehow
  def set_active_buf(rdx, new_buf) do
    case rdx.apps.editor.buffers
         |> Enum.find_index(fn buf -> buf.name == new_buf end) do
      nil ->
        raise "Can not set active buffer to a buffer that doesn't exist"

      b_num when is_integer(b_num) ->
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
