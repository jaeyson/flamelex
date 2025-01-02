defmodule Flamelex.GUI.Component.Kommander.Mutator do

  def reset_kommander(rdx) do
    Quillex.Buffer.BufferManager.call_buffer(rdx.apps.kommander.buf_ref, {:action, [:empty_buffer]})

    rdx
  end
end
