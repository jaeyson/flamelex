defmodule Flamelex.Fluxus.Supervisor do
  @moduledoc """
  Flamelex.Fluxus.Soup is the top-level supervisor for the Fluxus
  architecture pattern in the Flamelex application.
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
      # fluxus_radix(args)

      # Flamelex.Fluxus
      # {Flamelex.Fluxus.RadixStore, init_rdx},
      # Flamelex.Fluxus.ActionListener,
      # Flamelex.Fluxus.UserInputListener,
      # # TODO this will probably blow up but whatever
      # # {Flamelex.Fluxus.MemexStore, init_rdx},
      # Flamelex.Fluxus.MemelexListener

      # # Memelex Fluxus processes
      # # {Registry, keys: :duplicate, name: Memelex.PubSub},
      # # Flamelex.Fluxus.MemexStore,
      # # Memelex.Fluxus.ActionListener,
      # # Memelex.Fluxus.UserInputListener
    ]

    # TODO make this :rest_for_one?
    Supervisor.init(children, strategy: :one_for_all)
  end

  defp pubsub_tree do
    # https://hexdocs.pm/elixir/1.12/Registry.html#module-using-as-a-dispatcher
    {Registry, keys: :duplicate, name: Flamelex.Fluxus.PubSub}
  end

  defp fluxus_radix(args) do
    {Flamelex.Fluxus.Radix, args}
    #  %{
    #  state_module: Flamelex.Fluxus.Structs.RadixState,
    #  args: args
    #  }}
  end
end
