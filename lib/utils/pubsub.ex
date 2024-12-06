defmodule Flamelex.Lib.Utils.PubSub do
  @registrar_proc Flamelex.Fluxus.PubSub
  @topic :radix_state_changes

  def subscribe do
    IO.puts "DEPRECATE THIS just always pass in the bloody topic when you PubSUIb.subscribe"
    subscribe(topic: @topic)
  end

  def subscribe(topic: t) do
    {:ok, _} = Registry.register(@registrar_proc, t, [])
    :ok
  end

  # def broadcast(state_change: chng) do
  #   Registry.dispatch(@registrar_proc, @topic, fn entries ->
  #     for {pid, _} <- entries, do: send(pid, {:state_change, chng})
  #   end)
  # end

  def broadcast(topic: topic, msg: msg) do
    Registry.dispatch(@registrar_proc, topic, fn entries ->
      # != self is supposed to prevent looped messages
      for {pid, _} <- entries, pid != self(), do: send(pid, msg)
    end)
  end
end
