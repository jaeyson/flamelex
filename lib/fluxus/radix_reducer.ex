defmodule Flamelex.Fluxus.RadixReducer do
  @moduledoc """
  The RootReducer for all flamelex actions.

  These pure-functions are called by ActionListener, to handle specific
  actions within the application. Every action that gets processed, is
  routed down to the sub-reducers, through this module. Every possible
  action, must also be declared inside this file.


  A reducer is a function that determines changes to an application's state.

  All the reducers in Flamelex.Fluxus (and this includes both action
  handlers, and user-input handlers) work the same way - they take in
  the application state, & an action, & return an updated state. They
  may also fire off side-effects along the way, including further actions.

  ```
  A reducer is a function that determines changes to an application's state.
  It uses the action it receives to determine this change. We have tools,
  like Redux, that help manage an application's state changes in a single
  store so that they behave consistently.
  ```
  https://css-tricks.com/understanding-how-reducers-are-used-in-redux/


  Here we have the function which `reduces` a radix_state and an action.

  Our main way of handling actions is simply to broadcast them on to the
  `:actions` broker, which will forward it to all the main Manager processes
  in turn (GUiManager, BufferManager, AgentManager, etc.)

  The reason for this is, what's going to happen is, say I send a command
  like `open_buffer` to open my journal. We spin up this action handler
  task - say that takes 2 seconds to run for some reason. If I send the
  same action again, another process will spin up. Eventually, they're
  both going to finish, and whoever is getting the results (FluxusRadix)
  is going to get 2 messages, and then have to handle the situation of
  dealing with double-processes of actions (yuck!)

  what we want to do instead is, the reducer broadcasts the message to
  the "actions" channel - all the managers are able to react to this event.
  """

  # If we try to open a TidBit and we're already in editor mode, don't switch to Memex mode
  # def process(%{root: %{active_app: active_app}} = radix_state, {
  #       Memelex.Fluxus.Reducers.TidbitReducer,
  #       {:open_tidbit,
  #        %{type: ["external", "textfile"], data: %{"filepath" => filepath}} = tidbit}
  #     })
  #     when active_app in [:desktop, :editor] do
  #   QuillEx.Reducers.BufferReducer.process(
  #     radix_state,
  #     {:open_buffer, %{file: filepath, mode: {:vim, :normal}}}
  #   )
  # end

  # def process(radix_state, {:widget_workbench, :open}) do
  #   {:ok, radix_state |> open_widget_workbench()}
  # end

  # def process(radix_state, :show_agents) do
  #   new_radix_state =
  #     radix_state
  #     |> put_in([:root, :active_app], :high_council)

  #   {:ok, new_radix_state}
  # end

  def process(
        %{
          layers: %{
            one: %{
              layout: :full_screen,
              active_app: {Flamelex.GUI.Component.TODOlist, todo_app_state}
            }
          }
        } = rdx_state,
        {[app: Flamelex.GUI.Component.TODOlist], {:open_todo, t}}
      ) do
    IO.puts("DEPRECATE USING TUPLE FOR ACTIVE APP WHEN ONLY ONE APPPPP")

    rdx_state
    |> put_in([:layers, :one, :layout], :split_screen)
    |> put_in([:layers, :one, :active_app], [
      {Flamelex.GUI.Component.TODOlist, todo_app_state},
      {Flamelex.GUI.Component.TODOdetails, t}
    ])
  end

  def process(
        %{
          layers: %{
            one: %{
              layout: :full_screen,
              active_app: [{Flamelex.GUI.Component.TODOlist, todo_app_state}]
            }
          }
        } = rdx_state,
        {[app: Flamelex.GUI.Component.TODOlist], {:open_todo, t}}
      ) do
    rdx_state
    |> put_in([:layers, :one, :layout], :split_screen)
    |> put_in([:layers, :one, :active_app], [
      {Flamelex.GUI.Component.TODOlist, todo_app_state},
      {Flamelex.GUI.Component.TODOdetails, t}
    ])
  end

  def process(
        %{
          layers: %{
            one: %{
              active_app: [
                {Flamelex.GUI.Component.TODOlist, todo_app_state},
                {Flamelex.GUI.Component.TODOdetails, t}
              ]
            }
          }
        } = rdx_state,
        {[app: Flamelex.GUI.Component.TODOlist], {:open_todo, new_todo}}
      ) do
    rdx_state
    |> put_in([:layers, :one, :active_app], [
      {Flamelex.GUI.Component.TODOlist, todo_app_state},
      {Flamelex.GUI.Component.TODOdetails, new_todo}
    ])
  end

  def app_is_active?(rdx_state, app) do
    # TODO this is one reason to clean up and just have active_apps as a list of only one item even if only one app is active
    case rdx_state[:layers][:one][:active_app] do
      {^app, _args} ->
        true

      app_list when is_list(app_list) ->
        Enum.reduce(app_list, false, fn {a, _}, acc ->
          if a == app do
            true
          else
            acc
          end
        end)
    end
  end

  # def process(
  #       %{
  #         layers: %{
  #           one: %{
  #             active_app: [
  #               {Flamelex.GUI.Component.TODOlist, todo_app_state},
  #               {Flamelex.GUI.Component.TODOdetails, t}
  #             ]
  #           }
  #         }
  #       } = rdx_state,
  #       {[app: Flamelex.GUI.Component.TODOlist], {:open_todo, new_todo}}
  #     ) do
  #   rdx_state
  #   |> put_in([:layers, :one, :active_app], [
  #     {Flamelex.GUI.Component.TODOlist, todo_app_state},
  #     {Flamelex.GUI.Component.TODOdetails, new_todo}
  #   ])
  # end

  def process(
        %{
          layers: %{
            one: %{
              active_app: [
                {Flamelex.GUI.Component.TODOlist, todo_app_state},
                {Flamelex.GUI.Component.TODOdetails, _t}
              ]
            }
          }
        } = rdx_state,
        {[app: Flamelex.GUI.Component.TODOdetails], :close_todo}
      ) do
    rdx_state
    |> put_in([:layers, :one, :layout], :full_screen)
    |> put_in([:layers, :one, :active_app], [
      {Flamelex.GUI.Component.TODOlist, todo_app_state}
    ])
  end

  def process(rdx_state, {[app: app], {:filter_todos, filter_by}}) do
    if rdx_state |> app_is_active?(app) do
      new_todos = Memelex.My.TODOs.all(filter: filter_by)

      # hack hack this to work for only havinbg one active app
      [{todo_list_module, app_state}] = rdx_state[:layers][:one][:active_app]

      new_app_state = app_state |> Map.put(:list, new_todos)
      # update_active_app(rdx_state, app, merge: %{todo_list: new_todos})
      # {:ok, new_rdx_state}= update_app_status(rdx_state, app, merge: %{todo_list: new_todos})
      # case update_app_status(rdx_state, app, merge: %{todo_list: new_todos}) do
      #   {:ok, new_rdx_state} ->
      #     new_rdx_state+

      #   :error ->
      #     rdx_state
      # end

      rdx_state
      |> put_in([:layers, :one, :active_app], [{todo_list_module, new_app_state}])

      #   {Flamelex.GUI.Component.TODOlist, filter_todos(rdx_state, filter_by)}
      # ])
    else
      rdx_state
    end

    # Logger.error("Unable to process action. #{inspect(action)}")
    # IO.inspect(rdx_state)
    # :ignore
  end

  def update_active_app(rdx_state, app, merge: new_state) do
    new_active_apps =
      rdx_state[:layers][:one][:active_app]
      |> Enum.map(fn
        {a, s} when a == app -> {a, s |> Map.merge(new_state)}
        {a, s} -> {a, s}
      end)

    rdx_state
    |> put_in([:layers, :one, :active_app], new_active_apps)

    # |> put_in([:layers, :one, :active_app], [
    #   {app, rdx_state[:layers][:one][:active_app][app] |> Map.merge(new_state)}
    # ])
  end

  require Logger

  def process(rdx_state, action) do
    Logger.error("Unable to process action. #{inspect(action)}")
    IO.inspect(rdx_state)
    :ignore
  end

  # def process(radix_state, :open_memex) do
  #   new_radix_state =
  #     radix_state
  #     |> put_in([:root, :active_app], :memex)

  #   {:ok, new_radix_state}
  # end

  # def process(radix_state, {reducer, action}) when is_atom(reducer) do
  #   # Instead of try catch, look in the module, see if there's a function called that.

  #   # That could be cool, if we make all actions an actual function in the processor??

  #   # If that fails/doesn't work, we want to look up custom keymaps in the my_modz.ex (???)

  #   try do
  #     reducer.process(radix_state, action)
  #   rescue
  #     e in FunctionClauseError ->
  #       IO.inspect(e)

  #       {:error,
  #        "#{__MODULE__} -- Reducer `#{inspect(reducer)}` could not match action: #{inspect(action)}"}
  #   end
  # end

  # # TODO here, we should have a module of transformations for the radix state!
  # # Make RadixState a struct!?!?
  # defp open_widget_workbench(radix_state) do
  #   Flamelex.Fluxus.Structs.RadixState.mutate(radix_state, :open_widget_workbench)
  # end
end
