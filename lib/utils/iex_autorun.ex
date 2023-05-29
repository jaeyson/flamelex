defmodule IExAutoRun do
  @moduledoc """
  This Elixir code will automatically be run when the Flamelex app starts.

  The `.iex.exs` file in the project is automatically read by mix/IEx
  (I'm not 100% sure exactly which it is...), and if you check that, you
  should see it contains

  Note that it is a *quote*, not a function. This code
  """

  # this macto gets executed whenever the application is started in IEx
  # via the `.iex.exs` file
  defmacro __using__(_) do
    quote do
      IO.puts("Executing the code in `Flamelex.IExAutoRun`, via the `.iex.exs` file...")

      # these are the highest level functions, make them available to the CLI user directly
      import Flamelex

      # require AutoAlias
      # AutoAlias.alias_modules(Flamelex.API)
      # AutoAlias.alias_modules(Memelex.My)

      alias Flamelex.API.{
        Buffer,
        Kommander,
        GUI,
        Diary
      }

      alias Memelex.My

      alias Memelex.My.{
        Journal,
        Wiki,
        TODOs
      }

      IExAutoRun.print_welcome_msg()
    end
  end

  def print_welcome_msg do
    IO.puts("

    Welcome to Flamelex
    -------------------
    v#{Flamelex.App.MixProject.version()}

    ")

    # " <> punctuated_quote())
  end

  # def punctuated_quote do
  #   q = Flamelex.API.Diary.random_quote()

  #   ~s(“#{q.text}”
  #    - #{q.author}

  #   )
  # end
end
