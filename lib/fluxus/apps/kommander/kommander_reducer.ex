defmodule Flamelex.GUI.Component.Kommander.Reducer do

  def process(rdx, {:insert, text, :at_cursor} = a) do
    Quillex.Buffer.BufferManager.call_buffer(rdx.apps.kommander.buf_ref, {:action, a})

    # ignore on this level, buffer can update & broadcast out any changesk but no radix level changes will occur
    :ignore
  end

end


#   @moduledoc false
#   use Flamelex.Lib.ProjectAliases
#   require Logger





#   def process(
#         %{kommander: %{buffer: %{cursors: [cursor]} = k_buf}} = radix_state,
#         {:modify_kommander, {:backspace, 1, :at_cursor}}
#       ) do
#     # TODO this is a dodgy implementation which only assumes one line...
#     if cursor.col == 1 do
#       :ignore
#     else
#       {before_cursor_text, after_and_under_cursor_text} =
#         k_buf.data |> String.split_at(cursor.col - 1)

#       {backspaced_text, _deleted_text} = before_cursor_text |> String.split_at(-1)

#       full_backspaced_line = backspaced_text <> after_and_under_cursor_text

#       new_k_buf =
#         %{k_buf | data: full_backspaced_line}
#         |> QuillEx.Structs.Buffer.update(%{cursor: %{line: cursor.line, col: cursor.col - 1}})

#       new_radix_state =
#         radix_state
#         |> put_in([:kommander, :buffer], new_k_buf)

#       {:ok, new_radix_state}
#     end
#   end

#   def process(radix_state, :execute) do
#     # IO.inspect radix_state.kommander.buffer.data
#     {:ok, _pid} =
#       Task.start(fn ->
#         res = Code.eval_string(radix_state.kommander.buffer.data, [], __ENV__)
#       end)

#     # {value, _binding} = Task.await(eval_task)
#     # IO.inspect value, label: "Kommander result"

#     :ok
#   end

#   def process(%{kommander: %{buffer: k_buf}} = radix_state, :clear) do
#     new_radix_state = radix_state |> put_in([:kommander, :buffer], %{k_buf | data: ""})

#     {:ok, new_radix_state}
#   end

#   def process(radix_state, action) do
#     IO.puts("#{__MODULE__} failed to process action: #{inspect(action)}")
#     raise "kommand raise"
#   end
# end
