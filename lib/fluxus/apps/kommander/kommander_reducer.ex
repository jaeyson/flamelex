defmodule Flamelex.GUI.Component.Kommander.Reducer do
  alias Flamelex.GUI.Component.Kommander
  require Logger

  def process(rdx, :open_kommander) do
    rdx
    |> Flamelex.GUI.Layers.Layer4.Mutator.open_kommander()
  end

  def process(rdx, :close_kommander) do
    rdx
    |> Flamelex.GUI.Layers.Layer4.Mutator.close_kommander()
    |> Kommander.Mutator.reset_kommander()
  end

  def process(rdx, {:insert, text, :at_cursor} = a) do
    Quillex.Buffer.BufferManager.call_buffer(rdx.apps.kommander.buf_ref, {:action, a})

    # ignore on this level, buffer can update & broadcast out any changesk but no radix level changes will occur
    :ignore
  end

  def process(rdx, {:delete, :before_cursor} = a) do
    Quillex.Buffer.BufferManager.call_buffer(rdx.apps.kommander.buf_ref, {:action, a})

    # ignore on this level, buffer can update & broadcast out any changesk but no radix level changes will occur
    :ignore
  end

  # def process(rdx, [{:insert, text, :at_cursor} = a]) do
  #   Logger.warning "this is absurd dont accept a list here, this is a reducer we can handle specific actions here! Lists are for input handlers returning multiple actions"
  #   Quillex.Buffer.BufferManager.call_buffer(rdx.apps.kommander.buf_ref, {:action, a})

  #   # ignore on this level, buffer can update & broadcast out any changesk but no radix level changes will occur
  #   :ignore
  # end

  def process(rdx, :execute_kommander) do

    #TODO eventually might need to handle multiple lines here...
    {:ok, %{data: [kommander_text]}} = Quillex.Buffer.Process.fetch_buf(rdx.apps.kommander.buf_ref)

    # do it in a task so it it crashes it doesnt matter
    {:ok, _pid} =
      Task.start(fn ->
        _res = Code.eval_string(kommander_text, [], __ENV__)
      end)

    # {value, _binding} = Task.await(eval_task)
    # IO.inspect value, label: "Kommander result"

    rdx
    |> process(:close_kommander)
  end

  def process(rdx, unmatched_action) do
    Logger.error "#{__MODULE__} failed to match action: #{inspect unmatched_action}"
    :ignore
  end
end

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
