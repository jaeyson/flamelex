defmodule Flamelex.GUI.Component.TODOdetails.State do
  use StructAccess
  alias Flamelex.Fluxus.RadixState

  defstruct tidbit: nil,
            scroll: {0, 0},
            edit_description?: false

  def new do
    %__MODULE__{}
  end

  # def set_turbo(%RadixState{} = rdx, turbo?) when is_boolean(turbo?) do
  #   put_in(rdx, [:apps, :todo_list, :turbo_scroll?], turbo?)
  # end
end
