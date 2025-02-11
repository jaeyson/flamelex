defmodule Flamelex.GUI.Component.RapidSelector.State do
  @moduledoc """
  This module defines and manages the state for the Rapid Selector component.
  The state holds information about the current story river, sidebar, and history.
  """
  use StructAccess
  alias Flamelex.GUI.Component.StoryRiver

  defstruct story_river: nil,
            sidebar: %{},
            history: %{keystrokes: []}

  # Initialize a new state using the struct
  def new do
    %__MODULE__{
      story_river: StoryRiver.State.new()
    }
  end

  # # Update the focused tidbit in story_river
  # def update_focussed_tidbit(%__MODULE__{} = state, new_tidbit) do
  #   update_in(state.story_river[:focussed_tidbit], fn _ -> new_tidbit end)
  # end

  # # Update the scroll position in story_river
  # def update_scroll(%__MODULE__{} = state, new_scroll) do
  #   update_in(state.story_river[:scroll], fn _ -> new_scroll end)
  # end

  # # Log a keystroke in history
  # def log_keystroke(%__MODULE__{} = state, keystroke) do
  #   update_in(state.history[:keystrokes], fn keystrokes -> [keystroke | keystrokes] end)
  # end

  # # Reset the state back to the default
  # def reset_state do
  #   new()
  # end

  # def new do
  #   %{
  #     story_river: %{
  #       focussed_tidbit: nil,
  #       open_tidbits: [],
  #       # TODO put the scroll in another process, then it a) will hopefully be more seperated and b) we can just update that one (maybe even just by calling update_opts) and don't have to re-render every component we're scrolling, which is kinda crazy
  #       scroll: {0, 0}
  #     },
  #     sidebar:
  #       %{
  #         # active_tab: :ctrl_panel,
  #         # search: %{
  #         #   active?: false,
  #         #   string: ""
  #         # }
  #       },
  #     history: %{
  #       keystrokes: []
  #       # actions:      []
  #     }
  #   }
  # end
end
