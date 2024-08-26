defmodule Flamelex.Fluxus.Radix do
  use GenServer
  require Logger

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(args) do
    # Use :continue to initialize state after normal GenServer startup
    # this prevents blocking the main app supervision tree's startup
    # since building the radix tree can take a while / might fail
    {:ok, args, {:continue, :sprout_state}}
  end

  # initialize state, off the main process tree bootup sequence
  def handle_continue(:sprout_state, args) do
    Logger.debug("#{__MODULE__} starting up...")

    # compute state changes in a task for safety
    case do_task(fn -> Flamelex.Fluxus.NeoRadixState.new(args) end) do
      {:ok, state} ->
        Logger.debug("#{__MODULE__} started successfully.")
        {:noreply, state}

      {:error, reason} ->
        Logger.error("#{__MODULE__} failed to start: #{inspect(reason)}")
        {:noreply, :error}
    end
  end

  # this function offloads work to an asynchronous task
  # and manages the result
  @task_timeout 5000
  defp do_task(task_fn) when is_function(task_fn, 0) do
    task = Task.async(task_fn)

    result = Task.yield(task, @task_timeout) || Task.shutdown(task, :brutal_kill)

    case result do
      {:ok, task_result} ->
        # Task completed successfully
        {:ok, task_result}

      nil ->
        # Task timed out
        {:error, :timeout}

      {:exit, _reason} ->
        # Task crashed or exited with an error
        {:error, :task_failed}
    end
  end
end
