defmodule Flamelex.GUI.TopMenuBar do

  # TODO automatically add a .gitignore into each memex directory so it's impossible to accidentally commit the memex - anything except the my_modz.ex file
  # note that although it can never be committed, we also make a my_secretz.ex file

  # TODO here, we could look into the Memex & conditionally add a custom menu
  def calc_menu_map(radix_state) do
    [
      {:sub_menu, "Flamelex",
       [
         {:sub_menu, "Editor",
          [
            {"toggle line nums", fn -> raise "no" end},
            {"toggle file tray", fn -> raise "no" end},
            {"toggle tab bar", fn -> raise "no" end},
            font_sub_menu()
          ]},
         {:sub_menu, "Kommander",
          [
            {"show", &Flamelex.API.Kommander.show/0},
            {"hide", &Flamelex.API.Kommander.hide/0}
          ]},
         {:sub_menu, "DevTools",
          [
            {"get radix state",
             fn -> Flamelex.API.DevTools.get_radix_state() |> IO.inspect() end},
            {"temet nosce", &Flamelex.temet_nosce/0}
          ]},
         widget_workbench(),
         re_source_shell(),
         quit()
       ]},
      {:sub_menu, "Buffer", buffer_menu(radix_state)},
      memex_top_level_menu(),
      {:sub_menu, "API",
       ScenicWidgets.MenuBar.modules_and_zero_arity_functions("Elixir.Flamelex.API")}
      # {"Help", [
      # GettingStarted
      # {"About Flamelex", &Flamelex.API.Misc.makers_mark/0}]},
    ]
  end

  def memex_top_level_menu do
    {:sub_menu, "Memex",
       [
         {"open", &Flamelex.API.Diary.open/0},
         {"close", &Flamelex.API.Diary.close/0},
         {"my_modz", fn -> Flamelex.API.Buffer.open(Memelex.Environment.my_modz_file()) end}
         # random
         # journal
       ]}
  end

  def buffer_menu(%{editor: %{buffers: []}} = _radix_state) do
    [
      {"new", &Flamelex.API.Buffer.new/0},
      {"save", &Flamelex.API.Buffer.save/0},
      {"close", &Flamelex.API.Buffer.close/0}
    ]
  end

  def font_sub_menu do
    {:sub_menu, "font",
             [
               {:sub_menu, "primary font",
                [
                  {"ibm plex mono",
                   fn ->
                     Flamelex.Fluxus.RadixStore.get()
                     |> QuillEx.Reducers.RadixReducer.change_font(:ibm_plex_mono)
                     |> Flamelex.Fluxus.RadixStore.update()
                   end},
                  {"roboto",
                   fn ->
                     Flamelex.Fluxus.RadixStore.get()
                     |> QuillEx.Reducers.RadixReducer.change_font(:roboto)
                     |> Flamelex.Fluxus.RadixStore.update()
                   end},
                  {"roboto mono",
                   fn ->
                     Flamelex.Fluxus.RadixStore.get()
                     |> QuillEx.Reducers.RadixReducer.change_font(:roboto_mono)
                     |> Flamelex.Fluxus.RadixStore.update()
                   end},
                  {"iosevka",
                   fn ->
                     Flamelex.Fluxus.RadixStore.get()
                     |> QuillEx.Reducers.RadixReducer.change_font(:iosevka)
                     |> Flamelex.Fluxus.RadixStore.update()
                   end},
                  {"source code pro",
                   fn ->
                     Flamelex.Fluxus.RadixStore.get()
                     |> QuillEx.Reducers.RadixReducer.change_font(:source_code_pro)
                     |> Flamelex.Fluxus.RadixStore.update()
                   end},
                  {"fira code",
                   fn ->
                     Flamelex.Fluxus.RadixStore.get()
                     |> QuillEx.Reducers.RadixReducer.change_font(:fira_code)
                     |> Flamelex.Fluxus.RadixStore.update()
                   end},
                  {"bitter",
                   fn ->
                     Flamelex.Fluxus.RadixStore.get()
                     |> QuillEx.Reducers.RadixReducer.change_font(:bitter)
                     |> Flamelex.Fluxus.RadixStore.update()
                   end}
                ]},
               {"make bigger",
                fn ->
                  Flamelex.Fluxus.RadixStore.get()
                  |> QuillEx.Reducers.RadixReducer.change_font_size(:increase)
                  |> Flamelex.Fluxus.RadixStore.update()
                end},
               {"make smaller",
                fn ->
                  Flamelex.Fluxus.RadixStore.get()
                  |> QuillEx.Reducers.RadixReducer.change_font_size(:decrease)
                  |> Flamelex.Fluxus.RadixStore.update()
                end}
             ]}
  end

  def buffer_menu(%{editor: %{buffers: open_buffers}} = _radix_state) do
    # build the open-buffers sub-menu & open the buffer when we click on one
    # TODO if the buffer is unsaved, put an * at the end of it
    open_bufs_sub_menu =
      open_buffers
      |> Enum.map(fn %{id: {:buffer, name} = buf_id} ->
        # NOTE: Wrap this call in it's closure so it's a function of arity /0
        {name, fn -> Flamelex.API.Buffer.switch(buf_id) end}
      end)

    [
      {:sub_menu, "open-buffers", open_bufs_sub_menu},
      {"new", &Flamelex.API.Buffer.new/0},
      #  {"list", &Flamelex.API.Buffer.new/0}, #TODO list should be an arrow-out menudown, that lists open buffers
      {"save", &Flamelex.API.Buffer.save/0},
      {"close", &Flamelex.API.Buffer.close/0}
    ]
  end

  def widget_workbench do
    {"widget wkb", &Flamelex.DevTools.widget_workbench/0}
  end

  def re_source_shell do
    {"re_source_shell", &Flamelex.Lib.Utils.TerminalIO.create_shell_alias/0}
  end

  def quit do
    {"quit", &Flamelex.API.quit/0}
  end

end
