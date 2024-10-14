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
        %{memex: %{active?: true}}
      else
        IO.puts("starting Flamelex (no Memex)...")
        %{memex: %{active?: false}}
      end

    # Quillex won't boot it's own GUI if we set this to true
    Application.put_env(:quillex, :started_by_flamelex?, true)

    # in mix.exs we disabled booting the Quillex app/sup-tree (runtime: false)
    # because it will automatically boot it's own GUI (and this happens
    # before we ever get a chance to set the environment
    # variable below, because deps get booted first) but now that
    # we have set the variable which disables the GUI, we should go ahead and boot Quillex
    {:ok, _apps_started} = Application.ensure_all_started(:quillex)

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
      {Flamelex.Fluxus.Supervisor, args},
      {Scenic, [Flamelex.GUI.viewport_config()]}
    ]
  end
end
