defmodule Flamelex.Lib.Utils.TerminalIO do
  # TODO all this

  def warn(string), do: print(:warn, string)

  def print(color, string) when color in [:warn, :light_red] do
    IO.ANSI.light_red()
    IO.puts(string)
    IO.ANSI.default_color()
  end

  # TODO deprecate below
  def red(string) do
    ~s|#{IO.ANSI.red()}#{string}#{IO.ANSI.default_color()}|
  end

  def green(string) do
    IO.puts(~s|#{IO.ANSI.green()}#{string}#{IO.ANSI.default_color()}|)
  end

  def light_red(string) do
    IO.puts(~s|#{IO.ANSI.light_red()}#{string}#{IO.ANSI.default_color()}|)
  end

  @doc """
  Please note that this example assumes that the user is running a Bash shell
  and stores their aliases in the ~/.bashrc file. You might need to adjust the code
  to handle other shells or configuration files.

  Also, keep in mind that changes to the ~/.bashrc file will only take effect
  after the user restarts their shell or runs source ~/.bashrc. You may want to
  inform the user about this or automatically restart their shell after creating
  the alias. However, be cautious when automatically restarting the shell,
  as it might disrupt the user's workflow.
  """
  def create_shell_alias do
    shell_command = """
    echo 'alias flx="cd #{File.cwd!()} && iex -S mix run"' >> ~/.bashrc
    """

    {output, exit_code} = System.cmd("bash", ["-c", shell_command])

    if exit_code == 0 do
      IO.puts("Alias 'flx' created successfully.")
    else
      IO.puts("Failed to create alias 'flx'.")
    end
  end

  def create_shell_alias_and_maybe_resource_shell do
    shell_command = """
    echo 'alias flx="cd #{File.cwd!()} && iex -S mix run"' >> ~/.bashrc
    """

    {output, exit_code} = System.cmd("bash", ["-c", shell_command])

    if exit_code == 0 do
      IO.puts("Alias 'flx' created successfully.")

      IO.write("Do you want to re-source your shell now? (y/n): ")
      user_input = IO.gets("") |> String.trim()

      if String.downcase(user_input) == "y" do
        {output, exit_code} = System.cmd("bash", ["-c", "source ~/.bashrc"])

        if exit_code == 0 do
          IO.puts("Shell re-sourced successfully.")
        else
          IO.puts("Failed to re-source the shell.")
        end
      else
        IO.puts(
          "You will need to restart your shell or run 'source ~/.bashrc' for the changes to take effect."
        )
      end
    else
      IO.puts("Failed to create alias 'flx'.")
    end
  end
end
