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
      egtyptian_heiroglyphs: "fonts/Noto_Sans_Egyptian_Hieroglyphs/NotoSansEgyptianHieroglyphs-Regular.ttf",
      # symbols_2: "fonts/Noto_Sans_Symbols_2/NotoSansSymbols2-Regular.ttf",
      noto_sans_semi_condensed_medium_italic: "fonts/Noto_Sans/static/NotoSans_SemiCondensed-MediumItalic.ttf",
      meroitic: "fonts/Noto_Sans_Meroitic/NotoSansMeroitic-Regular.ttf",
      noto_sans_symbols: "fonts/Noto_Sans_Symbols/static/NotoSansSymbols-Regular.ttf"
    ]
end
