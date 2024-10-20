defmodule MyApp.Rainbow do
  def colors(steps \\ 360) do
    Enum.map(0..(steps - 1), fn i ->
      hue = i / steps
      hsv_to_rgb({hue, 1.0, 1.0})
    end)
  end

  defp hsv_to_rgb({h, s, v}) do
    h_i = floor(h * 6)
    f = h * 6 - h_i
    p = v * (1 - s)
    q = v * (1 - f * s)
    t = v * (1 - (1 - f) * s)

    {r, g, b} =
      case rem(h_i, 6) do
        0 -> {v, t, p}
        1 -> {q, v, p}
        2 -> {p, v, t}
        3 -> {p, q, v}
        4 -> {t, p, v}
        5 -> {v, p, q}
      end

    {round(r * 255), round(g * 255), round(b * 255)}
  end
end
