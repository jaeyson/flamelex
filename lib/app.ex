defmodule Flamelex.App do
  @moduledoc false
  use Application
  require Logger

  def start(_type, _args) do
    Logger.info("#{__MODULE__} initializing...")

    init_radix_state =
      if boot_memelex?() do
        IO.puts("attempting to boot Memex...")
        :ok = start_memelex()

        Flamelex.Fluxus.Structs.RadixState.initialize(%{
          memex: %{
            active?: true
          }
        })
      else
        IO.puts("starting Flamelex (no Memex)...")

        Flamelex.Fluxus.Structs.RadixState.initialize(%{
          memex: %{
            active?: false
          }
        })
      end

    children = start_flamelex(init_radix_state)

    opts = [strategy: :one_for_one, name: __MODULE__]
    Supervisor.start_link(children, opts)
  end

  def boot_memelex? do
    Application.get_env(:memelex, :active?, false)
  end

  defp start_memelex do
    Application.put_env(:memelex, :started_by_flamelex?, true)
    {:ok, _apps_started} = Application.ensure_all_started(:memelex)
    :ok
  end

  defp start_flamelex(radix_state) do
    [
      {Flamelex.Fluxus.TopLevelSupervisor, radix_state},
      {Scenic, [Flamelex.GUI.viewport_config()]}
    ]
  end
end
