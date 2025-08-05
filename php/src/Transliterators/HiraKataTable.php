<?php

declare(strict_types=1);

namespace Yosina\Transliterators;

/**
 * Shared hiragana-katakana mapping table
 */
class HiraKataTable
{
    private function __construct() {}

    /**
     * Main hiragana-katakana table
     * @var array<array{string,string,string,string,string,string,string}>
     */
    public const HIRAGANA_KATAKANA_TABLE = [
        // Vowels
        ['あ', '', '', 'ア', '', '', 'ｱ'],
        ['い', '', '', 'イ', '', '', 'ｲ'],
        ['う', 'ゔ', '', 'ウ', 'ヴ', '', 'ｳ'],
        ['え', '', '', 'エ', '', '', 'ｴ'],
        ['お', '', '', 'オ', '', '', 'ｵ'],
        // K-row
        ['か', 'が', '', 'カ', 'ガ', '', 'ｶ'],
        ['き', 'ぎ', '', 'キ', 'ギ', '', 'ｷ'],
        ['く', 'ぐ', '', 'ク', 'グ', '', 'ｸ'],
        ['け', 'げ', '', 'ケ', 'ゲ', '', 'ｹ'],
        ['こ', 'ご', '', 'コ', 'ゴ', '', 'ｺ'],
        // S-row
        ['さ', 'ざ', '', 'サ', 'ザ', '', 'ｻ'],
        ['し', 'じ', '', 'シ', 'ジ', '', 'ｼ'],
        ['す', 'ず', '', 'ス', 'ズ', '', 'ｽ'],
        ['せ', 'ぜ', '', 'セ', 'ゼ', '', 'ｾ'],
        ['そ', 'ぞ', '', 'ソ', 'ゾ', '', 'ｿ'],
        // T-row
        ['た', 'だ', '', 'タ', 'ダ', '', 'ﾀ'],
        ['ち', 'ぢ', '', 'チ', 'ヂ', '', 'ﾁ'],
        ['つ', 'づ', '', 'ツ', 'ヅ', '', 'ﾂ'],
        ['て', 'で', '', 'テ', 'デ', '', 'ﾃ'],
        ['と', 'ど', '', 'ト', 'ド', '', 'ﾄ'],
        // N-row
        ['な', '', '', 'ナ', '', '', 'ﾅ'],
        ['に', '', '', 'ニ', '', '', 'ﾆ'],
        ['ぬ', '', '', 'ヌ', '', '', 'ﾇ'],
        ['ね', '', '', 'ネ', '', '', 'ﾈ'],
        ['の', '', '', 'ノ', '', '', 'ﾉ'],
        // H-row
        ['は', 'ば', 'ぱ', 'ハ', 'バ', 'パ', 'ﾊ'],
        ['ひ', 'び', 'ぴ', 'ヒ', 'ビ', 'ピ', 'ﾋ'],
        ['ふ', 'ぶ', 'ぷ', 'フ', 'ブ', 'プ', 'ﾌ'],
        ['へ', 'べ', 'ぺ', 'ヘ', 'ベ', 'ペ', 'ﾍ'],
        ['ほ', 'ぼ', 'ぽ', 'ホ', 'ボ', 'ポ', 'ﾎ'],
        // M-row
        ['ま', '', '', 'マ', '', '', 'ﾏ'],
        ['み', '', '', 'ミ', '', '', 'ﾐ'],
        ['む', '', '', 'ム', '', '', 'ﾑ'],
        ['め', '', '', 'メ', '', '', 'ﾒ'],
        ['も', '', '', 'モ', '', '', 'ﾓ'],
        // Y-row
        ['や', '', '', 'ヤ', '', '', 'ﾔ'],
        ['ゆ', '', '', 'ユ', '', '', 'ﾕ'],
        ['よ', '', '', 'ヨ', '', '', 'ﾖ'],
        // R-row
        ['ら', '', '', 'ラ', '', '', 'ﾗ'],
        ['り', '', '', 'リ', '', '', 'ﾘ'],
        ['る', '', '', 'ル', '', '', 'ﾙ'],
        ['れ', '', '', 'レ', '', '', 'ﾚ'],
        ['ろ', '', '', 'ロ', '', '', 'ﾛ'],
        // W-row
        ['わ', '', '', 'ワ', 'ヷ', '', 'ﾜ'],
        ['ゐ', '', '', 'ヰ', 'ヸ', '', ''],
        ['ゑ', '', '', 'ヱ', 'ヹ', '', ''],
        ['を', '', '', 'ヲ', 'ヺ', '', 'ｦ'],
        ['ん', '', '', 'ン', '', '', 'ﾝ'],
    ];

    /**
     * Small kana table
     * @var array<array{string,string,string}>
     */
    public const HIRAGANA_KATAKANA_SMALL_TABLE = [
        ['ぁ', 'ァ', 'ｧ'],
        ['ぃ', 'ィ', 'ｨ'],
        ['ぅ', 'ゥ', 'ｩ'],
        ['ぇ', 'ェ', 'ｪ'],
        ['ぉ', 'ォ', 'ｫ'],
        ['っ', 'ッ', 'ｯ'],
        ['ゃ', 'ャ', 'ｬ'],
        ['ゅ', 'ュ', 'ｭ'],
        ['ょ', 'ョ', 'ｮ'],
        ['ゎ', 'ヮ', ''],
        ['ゕ', 'ヵ', ''],
        ['ゖ', 'ヶ', ''],
    ];

    /**
     * Generate voiced characters table for HiraKataCompositionTransliterator
     * @return array<string,string>
     */
    public static function generateVoicedCharacters(): array
    {
        $result = [];

        foreach (self::HIRAGANA_KATAKANA_TABLE as $entry) {
            // Add hiragana voiced mappings
            if ($entry[0] !== '' && $entry[1] !== '') {
                $result[$entry[0]] = $entry[1];
            }

            // Add katakana voiced mappings
            if ($entry[3] !== '' && $entry[4] !== '') {
                $result[$entry[3]] = $entry[4];
            }
        }

        // Add iteration marks
        $result["\u{309d}"] = "\u{309e}"; // ゝ -> ゞ
        $result["\u{30fd}"] = "\u{30fe}"; // ヽ -> ヾ
        $result["\u{3031}"] = "\u{3032}"; // 〱 -> 〲 (vertical hiragana)
        $result["\u{3033}"] = "\u{3034}"; // 〳 -> 〴 (vertical katakana)

        return $result;
    }

    /**
     * Generate semi-voiced characters table for HiraKataCompositionTransliterator
     * @return array<string,string>
     */
    public static function generateSemiVoicedCharacters(): array
    {
        $result = [];

        foreach (self::HIRAGANA_KATAKANA_TABLE as $entry) {
            // Add hiragana semi-voiced mappings
            if ($entry[0] !== null && $entry[2] !== '') {
                $result[$entry[0]] = $entry[2];
            }

            // Add katakana semi-voiced mappings
            if ($entry[5] !== '') {
                $result[$entry[3]] = $entry[5];
            }
        }

        return $result;
    }

    /**
     * Generate GR table for JIS X 0201 (katakana fullwidth to halfwidth)
     * @return array<string,string>
     */
    public static function generateGRTable(): array
    {
        $result = [
            "\u{3002}" => "\u{ff61}",  // 。 to ｡
            "\u{300c}" => "\u{ff62}",  // 「 to ｢
            "\u{300d}" => "\u{ff63}",  // 」 to ｣
            "\u{3001}" => "\u{ff64}",  // 、 to ､
            "\u{30fb}" => "\u{ff65}",  // ・ to ･
            "\u{30fc}" => "\u{ff70}",  // ー to ｰ
            "\u{309b}" => "\u{ff9e}",  // ゛ to ﾞ
            "\u{309c}" => "\u{ff9f}",  // ゜to ﾟ
        ];

        // Add katakana mappings from main table
        foreach (self::HIRAGANA_KATAKANA_TABLE as $entry) {
            if ($entry[6] !== '') {
                $result[$entry[3]] = $entry[6];
            }
        }

        // Add small kana mappings
        foreach (self::HIRAGANA_KATAKANA_SMALL_TABLE as $entry) {
            if ($entry[2] !== '') {
                $result[$entry[1]] = $entry[2];
            }
        }

        return $result;
    }

    /**
     * Generate voiced letters table for JIS X 0201
     * @return array<string,string>
     */
    public static function generateVoicedLettersTable(): array
    {
        $result = [];

        foreach (self::HIRAGANA_KATAKANA_TABLE as $entry) {
            if ($entry[6] !== '') {
                if ($entry[4] !== '') {
                    $result[$entry[4]] = "{$entry[6]}\u{ff9e}";
                }
                if ($entry[5] !== '') {
                    $result[$entry[5]] = "{$entry[6]}\u{ff9f}";
                }
            }
        }

        return $result;
    }

    /**
     * Generate hiragana table for JIS X 0201
     * @return array<string,string>
     */
    public static function generateHiraganaTable(): array
    {
        /** @var array<string,string> */
        $result = [];

        // Add main table hiragana mappings
        foreach (self::HIRAGANA_KATAKANA_TABLE as $entry) {
            if ($entry[0] !== '' && $entry[6] !== '') {
                $result[$entry[0]] = $entry[6];
                if ($entry[1] !== '') {
                    $result[$entry[1]] = "{$entry[6]}\u{ff9e}";
                }
                if ($entry[2] !== '') {
                    $result[$entry[2]] = "{$entry[6]}\u{ff9f}";
                }
            }
        }

        // Add small kana mappings
        foreach (self::HIRAGANA_KATAKANA_SMALL_TABLE as $entry) {
            if ($entry[2] !== '') {
                $result[$entry[1]] = $entry[2];
            }
        }

        return $result;
    }
}
