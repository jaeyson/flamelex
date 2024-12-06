defmodule Flamelex.GUI.Component.QlxWrap.State do
  @moduledoc """
  State management for the QlxWrap component.
  """
  use StructAccess

  defstruct buffers: [],
            # it's layers all the way down baby...
            # implement a layer system for the QlxWrap component
            layers: [],
            req_save: %{
              do?: false,
              buf: nil,
              data: nil
            },
            font: nil,
            active_buf: nil

  def new do
    %__MODULE__{font: font()}
  end

  def font do
    font_size = 24
    font_name = :ibm_plex_mono

    {:ok, font_metrics} = TruetypeMetrics.load("./assets/fonts/IBM_Plex_Mono/IBMPlexMono-Regular.ttf")

    Quillex.Structs.BufState.Font.new(%{
      name: font_name,
      size: font_size,
      metrics: font_metrics
    })
  end
end
