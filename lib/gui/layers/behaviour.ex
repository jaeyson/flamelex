# defmodule Flamelex.GUI.Layer.Behaviour do
#   # TODO document all this lol

#   # take in the radix_state and return a derived state which describes the layer
#   # this is necessary because we use this to determinne if the layer has changed & thus needs to be redrawn
#   @callback cast(map()) :: map()

#   # take in the layer_state and return the graph describing the layer
#   # TODO this now takes in a viewport & a dstruct
#   @callback render(map()) :: %Scenic.Graph{}
# end
