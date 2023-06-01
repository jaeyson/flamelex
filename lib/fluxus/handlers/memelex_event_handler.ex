defmodule Flamelex.Fluxus.MemelexEventHandler do
  @moduledoc """
  This is the highest-level input handler. All user-input gets routed
  through this module.
  """
  require Logger

  def process(radix_state, memex_state, {:loaded_memex, new_memex_env}) do
    new_radix_state =
      radix_state
      |> put_in([:memex, :env], new_memex_env)
      |> Flamelex.Fluxus.Structs.RadixState.calc_menu_map()

    {:ok, new_radix_state, memex_state}
  end

  def process(radix_state, memex_state, {:open_tidbit, t}) do
    {:ok, new_memex_state} =
      Memelex.Fluxus.Reducers.TidbitReducer.process(memex_state, {:open_tidbit, t})

    {:ok, radix_state, new_memex_state}
  end

  def process(_radix_state, _memex_state, event) do
    # Flamelex.Keymaps.Kommander |> process_with_rescue(radix_state, input)
    Logger.info("Got MemelexEvent: #{inspect(event)}")
    :ignore
  end
end

# def process(%{root: %{active_app: :desktop}} = radix_state, input) do
#   Flamelex.Keymaps.Desktop |> process_with_rescue(radix_state, input)
# end

# def process(%{root: %{active_app: :editor}} = radix_state, input) do
#   # TODO route this to QuillEx
#   # QuillEx.Fluxus.input(input)
#   Flamelex.Keymaps.Editor |> process_with_rescue(radix_state, input)
# end

# def process(%{root: %{active_app: :memex}} = radix_state, input) do
#   # fire it off to Memelex, they can worry about this one...
#   Memelex.Fluxus.input(input)
#   :ignore
# end

# def process(_radix_state, input) do
#   Logger.warn("ignoring input: #{inspect(input)}")
#   :ignore
# end

# # ------

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
