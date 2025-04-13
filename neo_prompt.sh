
LAYER_1_FILE="./lib/gui/layers/layer_1/laye_1.ex"

prompt = """
I need help on my Elixir/Scenic project. I have developed an internal architecture of the project which is supposed to be based on the `flux` architecture that React is based off - immutable actions get passed through pure-function reducers to return changes to a state. This state change gets broadcast out and components react to those changes.

I have learned a lot about working with Scenic and I have developed some patterns which help me to develop components. To assist you, I will step you through my application as much as possible to explain how everything works, and why I have established the patterns that I have.

When the app boots, I start a Scenic Scene. This Scene boots some sub-components which I call 'layers', logically they act as layers but really they're just Scenic components. This is some code from that root scene showing where I add the layers:

```
full_graph =
    Scenic.Graph.build()
    |> Layer0.add_to_graph(%{frame: app_frame})
    |> Layer01.add_to_graph(%{frame: app_frame})
    |> NeoLayer02.add_to_graph(%{
    id: :menubar,
    frame: full_window,
    state: NeoLayer02.cast_rdx_to_layer_state(radix_state)
    })
    # popups & modals
    |> Layer3.add_to_graph(%{frame: app_frame})
    # Kommander
    |> Layer4.add_to_graph(%{frame: app_frame})
```

Let's look at one of the layers. Here, this is layer 1 component:

```
cat "$LAYER_1_FILE"
```
"""