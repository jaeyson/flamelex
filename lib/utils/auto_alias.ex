# defmodule AutoAlias do

#   defmacro alias_modules({:__aliases__, _call_stack, namespace}) do
#     # Convert the given namespace to a string
#     # prefix = Atom.to_string(namespace)

#     # Find all modules with the given prefix
#     # modules = find_modules_with_prefix(prefix)

#     # # Build a list of quoted aliases
#     # aliases =
#     #   Enum.map(modules, fn module ->
#     #     module_name = String.replace_prefix(Atom.to_string(module), prefix <> ".", "")
#     #     quote do
#     #       alias unquote(module), as: unquote(String.to_atom(module_name))
#     #     end
#     #   end)

#     # # Return the list of aliases as a single quoted expression
#     quote do
#     #   unquote_splicing(aliases)
#       alias Memelex.My
#     end
#   end

#   def find_modules_with_prefix(prefix) do
#     # Get all loaded modules
#     loaded_modules = :code.all_loaded()

#     # Filter modules by the given prefix
#     Enum.filter(loaded_modules, fn {module, _} ->
#       # Convert the module name to a string
#       module_string = Atom.to_string(module)

#       # Check if the module string starts with the prefix
#       String.starts_with?(module_string, prefix)
#     end)
#     |> Enum.map(fn {module, _} -> module end)
#   end
# end
