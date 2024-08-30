defmodule Flamelex.Fluxus.NeoRadixState do
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
      memex: %{
        active?: false,
        env: nil
      },
      fonts: %{
        ibm_plex_mono: %{
          metrics: ibm_plex_mono_font_metrics
        }
      }
      # layers: []
    }
  end

  def theme do
    Scenic.Primitive.Style.Theme.preset(:light)
    |> Scenic.Primitive.Style.Theme.normalize()
  end
end
