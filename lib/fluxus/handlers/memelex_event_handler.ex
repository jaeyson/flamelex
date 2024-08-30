defmodule Flamelex.Fluxus.MemelexEventHandler do
  @moduledoc """
  This is where Flamelex is able to handle events from Memelex.
  """
  require Logger

  def process(radix_state, {:loaded_memex, new_memex_env}) do
    radix_state
    # TODO when I eventually go multi-env, this may be a problem...
    |> put_in([:memex, :active?], true)
    |> put_in([:memex, :env], new_memex_env)

    # |> Flamelex.Fluxus.Structs.RadixState.calc_menu_map()
  end

  def process(radix_state, :show_todos) do
    raise("THIS IS SUPPOSED TO SO THE THING")

    # notes - this should really be cleaner, but in principle
    # it's a very simple way to define the logic.. the problem is that
    # although this is basically where we want to define the logic of
    # what changes when we get "show_todos", we don't want to have to
    # know the details of how RadixState works... we just want to declare
    # what we want to happen, on the level of this module at least...

    # that's why a "Layer01.show_todos" function would be nice, but it
    # will go hand in hand with some of the other layer refacoring I want
    # to do, which will mean instead of creating the same 'type' of ScenicComponent,
    # the 'Layer' component, I'm going to just create new LayerComponents
    # which implement a layer behaviour - then instead of needing to define
    # layer structs and cast functions and etc etc, I want to be able to just
    # have the layer components implement the behaviour, and then a reducer
    # function will be able to convert radix_state to radix_state for certain actions

    # new_radix_state =
    #   radix_state
    #   # |> Flamelex.GUI.Layers.Layer01.show_todos()
    #   |> put_in([:root, :layers, :one, :layout], %{todo_list: :full_screen})

    #   |> put_in([:root, :active_app], :todos)

    # Fluxus.radixify(radix_state, :todos)

    # new_radix_state =
    #   radix_state
    #   |> Layer01.

    # {:ok, Flamelex.GUI.Layers.Layer01.show_todo_list(radix_state, :full_screen)}

    # {:ok, Fluxus.radixify(radix_state, :todos)}
  end

  # def process(_rdx, unknown_event) do
  #   IO.puts("GOT #{inspect(unknown_event)}")
  #   :ignore
  # end

  # def process(radix_state, memex_state, {:loaded_memex, new_memex_env}) do
  #   new_radix_state =
  #     radix_state
  #     |> put_in([:memex, :env], new_memex_env)
  #     |> Flamelex.Fluxus.Structs.RadixState.calc_menu_map()

  #   {:ok, new_radix_state, memex_state}
  # end

  # def process(
  #       radix_state,
  #       memex_state,
  #       {:reloaded_my_modz, %{env_modz_module: mod} = new_memex_env}
  #     )
  #     when is_atom(mod) do
  #   IO.puts("YES YES RELOADED MY MODZ")

  #   # raise "where are we..."

  #   new_radix_state =
  #     radix_state
  #     |> put_in([:memex, :env], new_memex_env)
  #     |> Flamelex.Fluxus.Structs.RadixState.calc_menu_map()

  #   {:ok, new_radix_state, memex_state}
  # end

  # def process(radix_state, memex_state, :show_agents) do
  #   Memelex.Utils.AgentUtils.show_agents()
  #   {:ok, radix_state, memex_state}
  # end

  # def process(radix_state, memex_state, {:open_tidbit, t}) do
  #   {:ok, new_memex_state} =
  #     Memelex.Fluxus.Reducers.TidbitReducer.process(memex_state, {:open_tidbit, t})

  #   {:ok, radix_state, new_memex_state}
  # end

  # def process(_radix_state, _memex_state, event) do
  #   # Flamelex.Keymaps.Kommander |> process_with_rescue(radix_state, input)
  #   Logger.info("Got MemelexEvent: #{inspect(event)}")
  #   :ignore
  # end
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
