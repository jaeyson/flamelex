defmodule Flamelex.GUI.Component.AgentHuddle.Mutator do
  @moduledoc """
  Functions to mutate the Radix state for the Agent huddle component.
  """

  alias Flamelex.Fluxus.RadixState

  def set_agent(%RadixState{} = rdx, %{uuid: tidbit_uuid}) do
    # Perform state mutation
    # raise "not implemented"
    # IO.puts("HERE WE WOULD PUT THE AGENT IN")
    t = Memelex.My.Wiki.get!(tidbit_uuid)

    rdx
    |> put_in([:apps, :agent_huddle, :tidbit], t)
  end

  def open_chat_window(rdx) do
    rdx
    |> put_in([:apps, :agent_huddle, :open_agent_five_loop?], false)
    |> put_in([:apps, :agent_huddle, :open_agent_settings?], false)
    |> put_in([:apps, :agent_huddle, :open_chat?], true)
  end

  def open_agent_settings(rdx) do
    rdx
    |> put_in([:apps, :agent_huddle, :open_chat?], false)
    |> put_in([:apps, :agent_huddle, :open_agent_five_loop?], false)
    |> put_in([:apps, :agent_huddle, :open_agent_settings?], true)
  end

  def open_agent_five_loop(rdx) do
    rdx
    |> put_in([:apps, :agent_huddle, :open_chat?], false)
    |> put_in([:apps, :agent_huddle, :open_agent_settings?], false)
    |> put_in([:apps, :agent_huddle, :open_agent_five_loop?], true)
  end

  def refresh_tidbit(rdx, %Memelex.TidBit{} = new_t) do
    rdx
    |> put_in([:apps, :agent_huddle, :tidbit], new_t)
  end
end
