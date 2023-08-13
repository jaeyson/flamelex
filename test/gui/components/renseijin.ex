defmodule Flamelex.GUI.Component.RenseijinTest do
  use ExUnit.Case, async: true
  import Flamelex.GUI.Component.Renseijin

  describe "init/3" do
    test "initializes the scene with correct attributes" do
      %Scenic.Scene{
        viewport: nil,
        pid: nil,
        module: nil,
        theme: nil,
        id: nil,
        parent: nil,
        children: nil,
        child_supervisor: nil,
        assigns: %{},
        supervisor: nil,
        stop_pid: nil
      } = scene = %Scenic.Scene{}

      args = %{}

      require IEx
      # IEx.pry(import: true)
      IEx.pry()

      {:ok, new_scene} = init(scene, args, [])

      # # Add relevant assertions here
      # assert new_scene.graph == expected_graph()
      # assert new_scene.frame == @args.frame
      # assert new_scene.rotation == 0
      # assert new_scene.animate? == @args.animate?
    end
  end

  defp expected_graph do
    # Compute or define the expected graph value based on the args or fixtures
  end
end
