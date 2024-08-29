defmodule Flamelex.Fluxus.TopLevelSupervisor do
  @moduledoc false
  use Supervisor
  require Logger

  def start_link(init_radix_state) do
    Supervisor.start_link(__MODULE__, init_radix_state, name: __MODULE__)
  end

  def init(init_rdx) do
    # Logger.debug "#{__MODULE__} initializing..."

    children = [
      # https://hexdocs.pm/elixir/1.12/Registry.html#module-using-as-a-dispatcher
      # {Registry, keys: :duplicate, name: Fluxus.PubSub},
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
end
