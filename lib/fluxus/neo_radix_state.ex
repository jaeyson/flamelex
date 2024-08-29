defmodule Flamelex.Fluxus.NeoRadixState do
  # def new(%{memex: %{active: true}}) do

  def new(_args) do
    {:ok, ibm_plex_mono_font_metrics} =
      TruetypeMetrics.load("./assets/fonts/IBMPlexMono-Regular.ttf")

    %{
      theme: theme(),
      menubar: %{
        font: :ibm_plex_mono,
        height: 60
      },
      editor: %{
        buffers: []
      },
      fonts: %{
        ibm_plex_mono: %{
          metrics: ibm_plex_mono_font_metrics
        }
      }
      # memex:
      #   %{
      #     # active: true
      #     # env: Memelex.environment_details()
      #   },
      # layers: []
    }
  end

  def theme do
    Scenic.Primitive.Style.Theme.preset(:light)
    |> Scenic.Primitive.Style.Theme.normalize()
  end
end
