defmodule Flamelex.Fluxus.Utils do
  #   @doc """
  #   This function is called to channel all user input, e.g. keypresses,
  #   through the FluxusRadix, where they can be converted into actions.

  #   This function handles user input. All input from the entire GUI gets
  #   routed through here (it gets sent here by Flamelex.GUI.RootScene.handle_input/3)

  #   We use the RadixState (which includes global variables such as which
  #   mode we are in, the input history [to allow chaining of keystrokes\] etc),
  #   as well as the input itself, to compute the new state.

  #   The effect of most user input will be either to ignore it, or to dispatch
  #   an action - this is achieved by sending a new msg to the FluxusRadix, which
  #   will in turn be handled by spinning up a new Task process to handle it.

  #     ##TODO it's simpler to route these different right now.
  #     # call Flamelex.Fluxus.UserInput.

  #     # This is an example of the "state-centered" approach - we keep
  #     # wanting to store things in the scene - maybe I should just put everything
  #     # in here lol

  #     # The whole idea of 'fluxus' is to seperate out the state of your
  #     # application, from the state of your Scenic GUI processes

  #     #TODO this is one area of quandary - either I spin up a new process
  #     # to handle everything (nice security), but then I have to wait here
  #     # for a callback. Or, if I don't wait, then I have to give up my
  #     # ability to mutate the scene here.

  #     # Maybe how this should work is - instead of messaging a GenServer
  #     # which holds the root state, we just start a process, which fetches
  #     # a copy of the root state inside itself?
  #   """
  @user_input :flx_user_input
  def user_input(ii) do
    EventBus.notify(%EventBus.Model.Event{
      id: UUID.uuid4(),
      topic: @user_input,
      data: {:user_input, ii}
    })
  end

  # this function offloads work to an asynchronous task
  # and returns that result or an error if the task fails
  @task_timeout :timer.seconds(3)
  def do_task(task_fn) when is_function(task_fn, 0) do
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
