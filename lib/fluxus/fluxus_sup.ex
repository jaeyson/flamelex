defmodule Flamelex.Fluxus.Supervisor do
  @moduledoc """
  Flamelex.Fluxus.Supervisor is the top-level supervisor for the
  Fluxus architecture pattern in the Flamelex application.
  """

  use Supervisor
  require Logger

  def start_link(_args) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_args) do
    Logger.debug("#{__MODULE__} initializing...")

    children = [
      Flamelex.Fluxus.RadixStore
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

end
