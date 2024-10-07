defmodule Flamelex.GUI.Component.QlxWrap.Mutator do
  # def set_agents(%RadixState{} = rdx, agents) do
  #   put_in(rdx, [:apps, :high_council, :agents], agents)
  # end

  # def set_new_agent_mode(%RadixState{} = rdx, new_agent_mode?) when is_boolean(new_agent_mode?) do
  #   put_in(rdx, [:apps, :high_council, :new_agent_mode?], new_agent_mode?)
  # end

  def add_open_buffer(rdx, buf_ref) do
    rdx
    |> put_in([:apps, :qlx_wrap, :buffers], rdx.apps.qlx_wrap.buffers ++ [buf_ref])
  end

  def set_active_buf(rdx, %Quillex.Structs.Buffer.BufRef{} = buf_ref) do
    case rdx.apps.qlx_wrap.buffers
         |> Enum.find_index(&(&1.uuid == buf_ref.uuid)) do
      nil ->
        raise "Can not set active buffer to a buffer that doesn't exist"

      b_num when is_integer(b_num) ->
        # TODO in the future we will have a more sophisticated way
        # of tracking the open buffers...
        {new_active_buf, remaining_bufs} = List.pop_at(rdx.apps.qlx_wrap.buffers, b_num)

        rdx
        |> put_in(
          [:apps, :qlx_wrap, :buffers],
          [new_active_buf] ++ remaining_bufs
        )
    end
  end
end
