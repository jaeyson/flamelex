defmodule Flamelex.Fluxus.NeoRadixState do
  # def new(%{memex: %{active: true}}) do

  def new(_args) do
    %{
      theme: theme(),
      # memex:
      #   %{
      #     # active: true
      #     # env: Memelex.environment_details()
      #   },
      layers: []
    }
  end

  def theme do
    Scenic.Primitive.Style.Theme.preset(:light)
    |> Scenic.Primitive.Style.Theme.normalize()
  end
end
