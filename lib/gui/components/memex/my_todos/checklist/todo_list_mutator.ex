defmodule Flamelex.GUI.Component.TODOlist.Mutator do
  @moduledoc """
  A collection of functions that mutate the radix state.
  """
  alias Flamelex.Fluxus.RadixState

  @default_filter {:top_priority, 25}

  def refresh_todo_list(%RadixState{} = rdx) do
    todo_list =
      if is_nil(rdx.apps.todo_list.filter) do
        Memelex.My.TODOs.all(filter: @default_filter)
      else
        Memelex.My.TODOs.all(filter: rdx.apps.todo_list.filter)
      end

    rdx |> put_in([:apps, :todo_list, :list], todo_list)
  end

  # def refresh_todo_list(%RadixState{} = rdx, filter: f) do
  #   todo_list = Memelex.My.TODOs.all(filter: f)
  #   rdx |> put_in([:apps, :todo_list, :list], todo_list)
  # end

  def set_turbo(%RadixState{} = rdx, turbo?) when is_boolean(turbo?) do
    put_in(rdx, [:apps, :todo_list, :turbo_scroll?], turbo?)
  end

  def set_filter(%RadixState{} = rdx, filter: f) do
    # NOTE I guess it's a touch *dangerous* not validating
    # the filter here, but we do validation inside the reducer,
    # adding further validation here is redundant and slows us down...

    # Since writring that ^^ comment, I have _also_ removed validation
    # from the reducer! We just assume the filter is valid, until it gets
    # propagated to My.TODOs and crashes !!?!

    # If we do add validation, do it right at the end, cause it's a lot of refactoring all the time right now having so much validation
    put_in(rdx, [:apps, :todo_list, :filter], f)
  end
end
