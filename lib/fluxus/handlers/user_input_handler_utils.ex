defmodule Flamelex.Fluxus.UserInputHandler.Utils do
  # defp process_with_rescue(reducer, radix_state, input) do
  #   try do
  #     reducer.process(radix_state, input)
  #   rescue
  #     FunctionClauseError ->
  #       Logger.warn("input: #{inspect(input)} not handled by Reducer `#{inspect(reducer)}`")
  #       # TODO should we still record this input??
  #       # {:ok, radix_state |> record_input(input)}
  #       :ignore
  #   else
  #     :ok ->
  #       {:ok, radix_state |> record_input(input)}

  #     # TODO I don't think we should allow any InputHandler to return a RadixState, since we dont broadcast out from them...
  #     # {:ok, new_radix_state} ->
  #     #    {:ok, new_radix_state |> record_input(input)}
  #     :ignore ->
  #       :ignore

  #     :error ->
  #       :error
  #   end
  # end

  # defp record_input(radix_state, {:key, {key, @key_pressed, []}} = input)
  #      when input in @valid_text_input_characters do
  #   # Logger.debug "-- Recording INPUT: #{inspect key}"
  #   # NOTE: We store the latest keystroke at the front of the list, not the back
  #   radix_state
  #   |> put_in([:history, :keystrokes], radix_state.history.keystrokes |> List.insert_at(0, input))
  # end

  # defp record_input(radix_state, input) do
  #   # Logger.debug "NOT recording: #{inspect input} as input..."
  #   radix_state
  # end
end
