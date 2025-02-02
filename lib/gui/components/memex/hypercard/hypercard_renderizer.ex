defmodule Memelex.GUI.Components.HyperCard.Renderizer do



  # def render(
  #   %Scenic.Graph{} = graph,
  #   %Scenic.Scene{assigns: %{state: %{frame: %Widgex.Frame{} = old_frame}}} = scene,
  #   %Widgex.Frame{} = new_frame,
  #   # %Layer3.State{} = state
  #   state
  # ) when old_frame != new_frame do
  #   # delete the old primitive to force a re-render from scratch
  #   graph
  #   # |> Scenic.Graph.delete(@layer_3)
  #   # |> draw_layer_3(new_frame, state)
  # end

  # defp hypercard()

  def render(graph, scene, frame, state) do
    graph
    |> Scenic.Primitives.rect(frame.size.box, fill: :red, translate: frame.pin.point)
  end

end


# defmodule Memelex.GUI.Components.HyperCard.Utils do
#     require Logger



#     def human_formatted_date(date) do
# 		Logger.debug "parsing date: #{inspect date} into human readable format..."
# 		{:ok, date, 0} = DateTime.from_iso8601(date)
# 		#IO.inspect date
# 		day = case Date.day_of_week(date) do
# 				1 -> "Mon"
# 				2 -> "Tue"
# 				3 -> "Wed"
# 				4 -> "Thu"
# 				5 -> "Fri"
# 				6 -> "Sat"
# 				7 -> "Sun"
# 			end
# 		month = case date.month do
# 				1 -> "Jan"
# 				2 -> "Feb"
# 				3 -> "Mar"
# 				4 -> "Apr"
# 				5 -> "May"
# 				6 -> "Jun"
# 				7 -> "Jul"
# 				8 -> "Aug"
# 				9 -> "Sep"
# 				10 -> "Oct"
# 				11 -> "Nov"
# 				12 -> "Dec"
# 			end
# 		"#{day} #{date.day} #{month} #{date.year}"
# 	end

# end
