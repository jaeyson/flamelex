defmodule Flamelex.Fluxus.Radix do
  use GenServer
  require Logger

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(args) do
    # use continue so that we dont block bootup of the supervision tree,
    # since building the radix tree can take a while / might fail
    {:ok, args, {:continue, :sprout_state}}
  end

  # here we build the initial state, after bootup so we don't block the supervision tree bootup process
  def handle_continue(:sprout_state, args) do
    Logger.debug("#{__MODULE__} starting up...")

    case do_task(&Flamelex.Fluxus.NeoRadixState.new(args)) do
      {:ok, state} ->
        {:noreply, state}

      {:error, reason} ->
        Logger.error("#{__MODULE__} failed to start: #{inspect(reason)}")
        {:noreply, :error}
    end
  end

  defp do_task(task_fn, state) when is_function(task_fn) do
    task = Task.async(task_fn)

    # Monitor the task and wait for it to complete, fail, or timeout
    result = Task.yield(task, @timeout) || Task.shutdown(task, :brutal_kill)

    case result do
      {:ok, task_result} ->
        # Handle successful task completion
        {:ok, task_result}

      nil ->
        # Task timed out
        {:error, :timeout}

      {:exit, reason} ->
        # Task crashed or exited with an error
        {:error, :task_failed}
    end
  end
end
