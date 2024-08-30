defmodule Flamelex.Fluxus.Supervisor do
  @moduledoc """
  Flamelex.Fluxus.Supervisor is the top-level supervisor for the
  Fluxus architecture pattern in the Flamelex application.
  """

  use Supervisor
  require Logger

  def start_link(init_args) do
    Supervisor.start_link(__MODULE__, init_args, name: __MODULE__)
  end

  def init(args) do
    Logger.debug("#{__MODULE__} initializing...")

    children = [
      pubsub_tree(),
      {Flamelex.Fluxus.Radix, args}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  defp pubsub_tree do
    # https://hexdocs.pm/elixir/1.12/Registry.html#module-using-as-a-dispatcher
    {Registry, keys: :duplicate, name: Flamelex.Fluxus.PubSub}
  end
end
