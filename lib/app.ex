defmodule Flamelex.App do
  @moduledoc false
  use Application
  require Logger

  def start(_type, _args) do
    Logger.info "#{__MODULE__} initializing..."

    rdx = Flamelex.Fluxus.Structs.RadixState.initialize(%{
      boot_memelex?: boot_memelex?()
    })

    children =
      if boot_memelex?(),
        do: start_memelex_first(rdx),
        else: start_flamelex(rdx)

    opts = [strategy: :one_for_one, name: __MODULE__]
    Supervisor.start_link(children, opts)
  end


  def boot_memelex? do
    Application.get_env(:memelex, :active?, false)
  end

  defp start_memelex_first(rdx) do
    [Memelex.App.BootLoader] ++ start_flamelex(rdx)
  end

  defp start_flamelex(radix_state) do
    [
      {Flamelex.Fluxus.TopLevelSupervisor, radix_state},
      {Scenic, [Flamelex.GUI.viewport_config()]}
    ]
  end
end
