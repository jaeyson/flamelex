defmodule Flamelex.GUI.Component.CodeBlock.State do
  @moduledoc """
  State management for the Code block component.
  """

  use StructAccess

  @default_title "file name here"
  @default_text ""

  defstruct [
    # Define state fields here
    title: "file name here",
    text: ""
  ]

  def new(args) when is_map(args) do
    %__MODULE__{
      title: args[:title] || @default_title,
      text: args[:text] || @default_text
    }
  end
end
