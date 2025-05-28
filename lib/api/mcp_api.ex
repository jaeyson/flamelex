defmodule Flamelex.API.MCP do
  @moduledoc """
  MCP API for Flamelex.
  
  This module provides functions that can be called via the MCP server
  to interact with Flamelex.
  """
  
  alias Flamelex.GUI
  
  @doc """
  Simple health check to verify the MCP connection is working.
  """
  def health_check do
    %{
      status: :ok,
      timestamp: DateTime.utc_now(),
      app: :flamelex,
      version: Application.spec(:flamelex, :vsn),
      node: Node.self()
    }
  end
  
  @doc """
  Get the current GUI state.
  """
  def get_gui_state do
    try do
      # Get current scene description
      scene_description = Flamelex.API.GUIIntrospector.describe_current_scene()
      
      # Get latest script summary
      script_summary = Flamelex.API.GUIIntrospector.get_latest_script_summary()
      
      # Get script analysis stats
      script_stats = Flamelex.API.ScriptAnalysis.get_stats()
      
      %{
        scene_description: scene_description,
        script_summary: script_summary,
        script_stats: script_stats,
        timestamp: DateTime.utc_now()
      }
    rescue
      e -> 
        %{error: Exception.message(e)}
    end
  end
  
  @doc """
  Send an input event to the GUI.
  """
  def send_input_event(event_type, params \\ %{}) do
    try do
      # Convert string keys to atoms
      atom_params = for {k, v} <- params, into: %{}, do: {String.to_atom(k), v}
      
      # Send the event to the GUI
      result = case event_type do
        "key" -> 
          GUI.handle_input({:key, atom_params}, nil)
        
        "click" ->
          {x, y} = {Map.get(atom_params, :x, 0), Map.get(atom_params, :y, 0)}
          GUI.handle_input({:cursor_button, {:left, :press, 0, {x, y}}}, nil)
          
        _ ->
          {:error, "Unknown event type: #{event_type}"}
      end
      
      %{
        status: :ok,
        result: result,
        timestamp: DateTime.utc_now()
      }
    rescue
      e -> 
        %{error: Exception.message(e)}
    end
  end
  
  @doc """
  Execute a GUI command.
  """
  def execute_gui_command(command, params \\ %{}) do
    try do
      # Convert string keys to atoms
      atom_params = for {k, v} <- params, into: %{}, do: {String.to_atom(k), v}
      
      # Execute the command
      result = apply(GUI, String.to_atom(command), [atom_params])
      
      %{
        status: :ok,
        result: result,
        timestamp: DateTime.utc_now()
      }
    rescue
      e -> 
        %{error: Exception.message(e)}
    end
  end
end
