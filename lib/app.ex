defmodule Flamelex.App do
  @moduledoc false
  use Application
  require Logger

  def start(_type, _args) do
    Logger.debug("#{__MODULE__} initializing...")

    init_args =
      if boot_memelex?() do
        IO.puts("attempting to boot Memex...")
        :ok = start_memelex()

        # Flamelex.Fluxus.Structs.RadixState.initialize(%{
        #   memex: %{
        #     active?: true
        #   }
        # })

        %{memex: %{active?: true}}
      else
        IO.puts("starting Flamelex (no Memex)...")

        # Flamelex.Fluxus.Structs.RadixState.initialize(%{
        #   memex: %{
        #     active?: false
        #   }
        # })

        %{memex: %{active?: false}}
      end

    children = start_flamelex(init_args)

    opts = [strategy: :one_for_one, name: __MODULE__]
    Supervisor.start_link(children, opts)
  end

  def restart do
    # IEx.recompile()
    Application.stop(:flamelex) && Application.start(:flamelex)
  end

  def boot_memelex? do
    Application.get_env(:memelex, :active?, false)
  end

  defp start_memelex do
    Application.put_env(:memelex, :started_by_flamelex?, true)
    {:ok, _apps_started} = Application.ensure_all_started(:memelex)
    :ok
  end

  defp start_flamelex(args) do
    [
      # Fluxus, which holds the application/GUI state
      # {Flamelex.Fluxus, %{init_args: init_args}},
      {Flamelex.Fluxus.Supervisor, args},
      # Listeners, which handle user input and other events
      # {Flamelex.Listeners.Supervisor,
      #  [
      #    Flamelex.Fluxus.ActionListener,
      #    Flamelex.Fluxus.UserInputListener,
      #    Flamelex.Fluxus.MemelexListener
      #  ]},
      {Scenic, [Flamelex.GUI.viewport_config()]}
    ]
  end
end
