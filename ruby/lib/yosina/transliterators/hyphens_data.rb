# frozen_string_literal: true

module Yosina
  module Transliterators
    # Generated hyphens data
    module HyphensData
      # Record for hyphen transliteration data
      HyphensRecord = Struct.new(:ascii, :jisx0201, :jisx0208_90, :jisx0208_90_windows, :jisx0208_verbatim, keyword_init: true) do
        def initialize(ascii: nil, jisx0201: nil, jisx0208_90: nil, jisx0208_90_windows: nil, jisx0208_verbatim: nil)
          super
        end
      end

      # Generated mapping data
      HYPHENS_MAPPINGS = {
        '-' => HyphensRecord.new(ascii: '-', jisx0201: '-', jisx0208_90: "\u{2212}", jisx0208_90_windows: "\u{2212}"),
        '|' => HyphensRecord.new(ascii: '|', jisx0201: '|', jisx0208_90: "\u{ff5c}", jisx0208_90_windows: "\u{ff5c}"),
        '~' => HyphensRecord.new(ascii: '~', jisx0201: '~', jisx0208_90: "\u{301c}", jisx0208_90_windows: "\u{ff5e}"),
        "\u{a2}" => HyphensRecord.new(jisx0208_90: "\u{a2}", jisx0208_90_windows: "\u{ffe0}"),
        "\u{a3}" => HyphensRecord.new(jisx0208_90: "\u{a3}", jisx0208_90_windows: "\u{ffe1}"),
        "\u{a6}" => HyphensRecord.new(ascii: '|', jisx0201: '|', jisx0208_90: "\u{ff5c}", jisx0208_90_windows: "\u{ff5c}"),
        "\u{2d7}" => HyphensRecord.new(ascii: '-', jisx0201: '-', jisx0208_90: "\u{2212}", jisx0208_90_windows: "\u{ff0d}"),
        "\u{2010}" => HyphensRecord.new(ascii: '-', jisx0201: '-', jisx0208_90: "\u{2010}", jisx0208_90_windows: "\u{2010}"),
        "\u{2011}" => HyphensRecord.new(ascii: '-', jisx0201: '-', jisx0208_90: "\u{2010}", jisx0208_90_windows: "\u{2010}"),
        "\u{2012}" => HyphensRecord.new(ascii: '-', jisx0201: '-', jisx0208_90: "\u{2015}", jisx0208_90_windows: "\u{2015}"),
        "\u{2013}" => HyphensRecord.new(ascii: '-', jisx0201: '-', jisx0208_90: "\u{2015}", jisx0208_90_windows: "\u{2015}"),
        "\u{2014}" => HyphensRecord.new(ascii: '-', jisx0201: '-', jisx0208_90: "\u{2014}", jisx0208_90_windows: "\u{2015}"),
        "\u{2015}" => HyphensRecord.new(ascii: '-', jisx0201: '-', jisx0208_90: "\u{2015}", jisx0208_90_windows: "\u{2015}"),
        "\u{2016}" => HyphensRecord.new(jisx0208_90: "\u{2016}", jisx0208_90_windows: "\u{2225}"),
        "\u{203e}" => HyphensRecord.new(jisx0201: '~', jisx0208_90: "\u{ffe3}", jisx0208_90_windows: "\u{ffe3}"),
        "\u{2043}" => HyphensRecord.new(ascii: '-', jisx0201: '-', jisx0208_90: "\u{2010}", jisx0208_90_windows: "\u{2010}"),
        "\u{2053}" => HyphensRecord.new(ascii: '~', jisx0201: '~', jisx0208_90: "\u{301c}", jisx0208_90_windows: "\u{301c}"),
        "\u{2212}" => HyphensRecord.new(ascii: '-', jisx0201: '-', jisx0208_90: "\u{2212}", jisx0208_90_windows: "\u{ff0d}"),
        "\u{2225}" => HyphensRecord.new(jisx0208_90: "\u{2016}", jisx0208_90_windows: "\u{2225}"),
        "\u{223c}" => HyphensRecord.new(ascii: '~', jisx0201: '~', jisx0208_90: "\u{301c}", jisx0208_90_windows: "\u{ff5e}"),
        "\u{223d}" => HyphensRecord.new(ascii: '~', jisx0201: '~', jisx0208_90: "\u{301c}", jisx0208_90_windows: "\u{ff5e}"),
        "\u{2500}" => HyphensRecord.new(ascii: '-', jisx0201: '-', jisx0208_90: "\u{2015}", jisx0208_90_windows: "\u{2015}"),
        "\u{2501}" => HyphensRecord.new(ascii: '-', jisx0201: '-', jisx0208_90: "\u{2015}", jisx0208_90_windows: "\u{2015}"),
        "\u{2502}" => HyphensRecord.new(ascii: '|', jisx0201: '|', jisx0208_90: "\u{ff5c}", jisx0208_90_windows: "\u{ff5c}"),
        "\u{2796}" => HyphensRecord.new(ascii: '-', jisx0201: '-', jisx0208_90: "\u{2212}", jisx0208_90_windows: "\u{ff0d}"),
        "\u{29ff}" => HyphensRecord.new(ascii: '-', jisx0201: '-', jisx0208_90: "\u{2010}", jisx0208_90_windows: "\u{ff0d}"),
        "\u{2e3a}" => HyphensRecord.new(ascii: '--', jisx0201: '--', jisx0208_90: "\u{2014}\u{2014}", jisx0208_90_windows: "\u{2015}\u{2015}"),
        "\u{2e3b}" => HyphensRecord.new(ascii: '---', jisx0201: '---', jisx0208_90: "\u{2014}\u{2014}\u{2014}", jisx0208_90_windows: "\u{2015}\u{2015}\u{2015}"),
        "\u{301c}" => HyphensRecord.new(ascii: '~', jisx0201: '~', jisx0208_90: "\u{301c}", jisx0208_90_windows: "\u{ff5e}"),
        "\u{30a0}" => HyphensRecord.new(ascii: '=', jisx0201: '=', jisx0208_90: "\u{ff1d}", jisx0208_90_windows: "\u{ff1d}"),
        "\u{30fb}" => HyphensRecord.new(jisx0201: "\u{ff65}", jisx0208_90: "\u{30fb}", jisx0208_90_windows: "\u{30fb}"),
        "\u{30fc}" => HyphensRecord.new(ascii: '-', jisx0201: '-', jisx0208_90: "\u{30fc}", jisx0208_90_windows: "\u{30fc}"),
        "\u{fe31}" => HyphensRecord.new(ascii: '|', jisx0201: '|', jisx0208_90: "\u{ff5c}", jisx0208_90_windows: "\u{ff5c}"),
        "\u{fe58}" => HyphensRecord.new(ascii: '-', jisx0201: '-', jisx0208_90: "\u{2010}", jisx0208_90_windows: "\u{2010}"),
        "\u{fe63}" => HyphensRecord.new(ascii: '-', jisx0201: '-', jisx0208_90: "\u{2010}", jisx0208_90_windows: "\u{2010}"),
        "\u{ff0d}" => HyphensRecord.new(ascii: '-', jisx0201: '-', jisx0208_90: "\u{2212}", jisx0208_90_windows: "\u{ff0d}"),
        "\u{ff5c}" => HyphensRecord.new(ascii: '|', jisx0201: '|', jisx0208_90: "\u{ff5c}", jisx0208_90_windows: "\u{ff5c}"),
        "\u{ff5e}" => HyphensRecord.new(ascii: '~', jisx0201: '~', jisx0208_90: "\u{301c}", jisx0208_90_windows: "\u{ff5e}"),
        "\u{ffe4}" => HyphensRecord.new(ascii: '|', jisx0201: '|', jisx0208_90: "\u{ff5c}", jisx0208_90_windows: "\u{ffe4}"),
        "\u{ff70}" => HyphensRecord.new(ascii: '-', jisx0201: "\u{ff70}", jisx0208_90: "\u{30fc}", jisx0208_90_windows: "\u{30fc}"),
        "\u{ffe8}" => HyphensRecord.new(ascii: '|', jisx0201: '|', jisx0208_90: "\u{ff5c}", jisx0208_90_windows: "\u{ff5c}")
      }.freeze
    end
  end
end
