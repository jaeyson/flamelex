defmodule Flamelex.App.Scenic.Assets do
  use Scenic.Assets.Static,
    otp_app: :flamelex,
    alias: [
      ibm_plex_mono: "fonts/IBM_Plex_Mono/IBMPlexMono-Regular.ttf",
      # mate: "fonts/Mate/Mate-Regular.ttf",
      # math: "fonts/Noto_Sans_Math/NotoSansMath-Regular.ttf",
      # emoji: "fonts/Noto_Emoji/static/NotoEmoji-Regular.ttf",
      # music: "fonts/Noto_Music/NotoMusic-Regular.ttf",
      noto_sans: "fonts/Noto_Sans/static/NotoSans-Regular.ttf",
      # symbols: "fonts/Noto_Sans_Symbols/static/NotoSansSymbols-Regular.ttf",
      # symbols_2: "fonts/Noto_Sans_Symbols_2/NotoSansSymbols2-Regular.ttf",
      meroitic: "fonts/Noto_Sans_Meroitic/NotoSansMeroitic-Regular.ttf"
      # ibm_plex_mono: "fonts/IBM_Plex_Mono/IBMPlexMono-Regular.ttf"
    ]
end
