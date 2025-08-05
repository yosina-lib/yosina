# frozen_string_literal: true

module Yosina
  module Transliterators
    # Hiragana-Katakana mapping table
    module HiraKataTable
      # Main hiragana-katakana table with [hiragana, katakana, halfwidth] structure
      HIRAGANA_KATAKANA_TABLE = [
        # Vowels
        [['あ', nil, nil], ['ア', nil, nil], 'ｱ'],
        [['い', nil, nil], ['イ', nil, nil], 'ｲ'],
        [['う', 'ゔ', nil], ['ウ', 'ヴ', nil], 'ｳ'],
        [['え', nil, nil], ['エ', nil, nil], 'ｴ'],
        [['お', nil, nil], ['オ', nil, nil], 'ｵ'],
        # K-row
        [['か', 'が', nil], ['カ', 'ガ', nil], 'ｶ'],
        [['き', 'ぎ', nil], ['キ', 'ギ', nil], 'ｷ'],
        [['く', 'ぐ', nil], ['ク', 'グ', nil], 'ｸ'],
        [['け', 'げ', nil], ['ケ', 'ゲ', nil], 'ｹ'],
        [['こ', 'ご', nil], ['コ', 'ゴ', nil], 'ｺ'],
        # S-row
        [['さ', 'ざ', nil], ['サ', 'ザ', nil], 'ｻ'],
        [['し', 'じ', nil], ['シ', 'ジ', nil], 'ｼ'],
        [['す', 'ず', nil], ['ス', 'ズ', nil], 'ｽ'],
        [['せ', 'ぜ', nil], ['セ', 'ゼ', nil], 'ｾ'],
        [['そ', 'ぞ', nil], ['ソ', 'ゾ', nil], 'ｿ'],
        # T-row
        [['た', 'だ', nil], ['タ', 'ダ', nil], 'ﾀ'],
        [['ち', 'ぢ', nil], ['チ', 'ヂ', nil], 'ﾁ'],
        [['つ', 'づ', nil], ['ツ', 'ヅ', nil], 'ﾂ'],
        [['て', 'で', nil], ['テ', 'デ', nil], 'ﾃ'],
        [['と', 'ど', nil], ['ト', 'ド', nil], 'ﾄ'],
        # N-row
        [['な', nil, nil], ['ナ', nil, nil], 'ﾅ'],
        [['に', nil, nil], ['ニ', nil, nil], 'ﾆ'],
        [['ぬ', nil, nil], ['ヌ', nil, nil], 'ﾇ'],
        [['ね', nil, nil], ['ネ', nil, nil], 'ﾈ'],
        [['の', nil, nil], ['ノ', nil, nil], 'ﾉ'],
        # H-row
        [['は', 'ば', 'ぱ'], ['ハ', 'バ', 'パ'], 'ﾊ'],
        [['ひ', 'び', 'ぴ'], ['ヒ', 'ビ', 'ピ'], 'ﾋ'],
        [['ふ', 'ぶ', 'ぷ'], ['フ', 'ブ', 'プ'], 'ﾌ'],
        [['へ', 'べ', 'ぺ'], ['ヘ', 'ベ', 'ペ'], 'ﾍ'],
        [['ほ', 'ぼ', 'ぽ'], ['ホ', 'ボ', 'ポ'], 'ﾎ'],
        # M-row
        [['ま', nil, nil], ['マ', nil, nil], 'ﾏ'],
        [['み', nil, nil], ['ミ', nil, nil], 'ﾐ'],
        [['む', nil, nil], ['ム', nil, nil], 'ﾑ'],
        [['め', nil, nil], ['メ', nil, nil], 'ﾒ'],
        [['も', nil, nil], ['モ', nil, nil], 'ﾓ'],
        # Y-row
        [['や', nil, nil], ['ヤ', nil, nil], 'ﾔ'],
        [['ゆ', nil, nil], ['ユ', nil, nil], 'ﾕ'],
        [['よ', nil, nil], ['ヨ', nil, nil], 'ﾖ'],
        # R-row
        [['ら', nil, nil], ['ラ', nil, nil], 'ﾗ'],
        [['り', nil, nil], ['リ', nil, nil], 'ﾘ'],
        [['る', nil, nil], ['ル', nil, nil], 'ﾙ'],
        [['れ', nil, nil], ['レ', nil, nil], 'ﾚ'],
        [['ろ', nil, nil], ['ロ', nil, nil], 'ﾛ'],
        # W-row
        [['わ', nil, nil], ['ワ', 'ヷ', nil], 'ﾜ'],
        [['ゐ', nil, nil], ['ヰ', 'ヸ', nil], nil],
        [['ゑ', nil, nil], ['ヱ', 'ヹ', nil], nil],
        [['を', nil, nil], ['ヲ', 'ヺ', nil], 'ｦ'],
        [['ん', nil, nil], ['ン', nil, nil], 'ﾝ']
      ].freeze

      # Small kana table
      HIRAGANA_KATAKANA_SMALL_TABLE = [
        ['ぁ', 'ァ', 'ｧ'],
        ['ぃ', 'ィ', 'ｨ'],
        ['ぅ', 'ゥ', 'ｩ'],
        ['ぇ', 'ェ', 'ｪ'],
        ['ぉ', 'ォ', 'ｫ'],
        ['っ', 'ッ', 'ｯ'],
        ['ゃ', 'ャ', 'ｬ'],
        ['ゅ', 'ュ', 'ｭ'],
        ['ょ', 'ョ', 'ｮ'],
        ['ゎ', 'ヮ', nil],
        ['ゕ', 'ヵ', nil],
        ['ゖ', 'ヶ', nil]
      ].freeze

      # Generate voiced character mappings
      def self.generate_voiced_characters
        result = []
        HIRAGANA_KATAKANA_TABLE.each do |hiragana, katakana, _|
          result << [hiragana[0], hiragana[1]] if hiragana[0] && hiragana[1]
          result << [katakana[0], katakana[1]] if katakana[0] && katakana[1]
        end
        # Add iteration marks
        result.concat([
                        ['ゝ', 'ゞ'],
                        ['ヽ', 'ヾ'],
                        ['〱', '〲'],  # U+3031 -> U+3032 (vertical hiragana)
                        ['〳', '〴']   # U+3033 -> U+3034 (vertical katakana)
                      ])
        result
      end

      # Generate semi-voiced character mappings
      def self.generate_semi_voiced_characters
        result = []
        HIRAGANA_KATAKANA_TABLE.each do |hiragana, katakana, _|
          result << [hiragana[0], hiragana[2]] if hiragana[0] && hiragana[2]
          result << [katakana[0], katakana[2]] if katakana[0] && katakana[2]
        end
        result
      end

      VOICED_CHARACTERS = generate_voiced_characters.freeze
      SEMI_VOICED_CHARACTERS = generate_semi_voiced_characters.freeze
    end
  end
end
