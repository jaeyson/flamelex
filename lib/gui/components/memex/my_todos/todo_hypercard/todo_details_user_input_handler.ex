# def process(
#       %{
#         layers: %{
#           one: %{
#             layout: :split_screen,
#             active_apps: [
#               {Flamelex.GUI.Component.TODOlist, todos},
#               {Flamelex.GUI.Component.TODOdetails, _args2}
#             ]
#           }
#         }
#       } = rdx,
#       @escape_key
#     ) do
#   rdx
#   |> put_in([:layers, :one, :layout], :full_screen)
#   |> put_in(
#     [:layers, :one, :active_apps],
#     [{Flamelex.GUI.Component.TODOlist, todos}]
#   )
# end
