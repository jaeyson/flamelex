defmodule Flamelex.GUI.Component.TODOdetails.State do
  use StructAccess
  alias Flamelex.Fluxus.RadixState

  defstruct tidbit: nil,
            scroll: {0, 0},
            edit_description?: false

  def new do
    %__MODULE__{}
  end

  def new(%{tidbit: %Memelex.TidBit{} = t}) do
    IO.puts "TODO rename this from new to update since we're updating the tidbit not making anything new"
    %__MODULE__{tidbit: t}
  end

  def update(%__MODULE__{} = state, %{tidbit: %Memelex.TidBit{} = t}) do
    %{state|tidbit: t}
  end

  # def set_turbo(%RadixState{} = rdx, turbo?) when is_boolean(turbo?) do
  #   put_in(rdx, [:apps, :todo_list, :turbo_scroll?], turbo?)
  # end

  def cast(%__MODULE__{} = state, %{edit_description?: mode?}) when is_boolean(mode?) do
    %{state | edit_description?: mode?}
  end
end
