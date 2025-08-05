<?php

declare(strict_types=1);

namespace Yosina\Transliterators;

use Yosina\Char;
use Yosina\TransliteratorInterface;

/**
 * Combines decomposed hiragana and katakana characters into composed equivalents.
 *
 * This transliterator handles composition of characters like か + ゙ -> が, combining
 * base characters with diacritical marks (dakuten and handakuten) into their
 * precomposed forms.
 */
class HiraKataCompositionTransliterator implements TransliteratorInterface
{
    /**
     * Composition table mapping [decomposed] => composed
     */
    private const COMPOSITION_TABLE = [
        // Hiragana with dakuten (voiced sound mark)
        "\u{304b}\u{3099}" => "\u{304c}",  // か + ゙ -> が
        "\u{304d}\u{3099}" => "\u{304e}",  // き + ゙ -> ぎ
        "\u{304f}\u{3099}" => "\u{3050}",  // く + ゙ -> ぐ
        "\u{3051}\u{3099}" => "\u{3052}",  // け + ゙ -> げ
        "\u{3053}\u{3099}" => "\u{3054}",  // こ + ゙ -> ご
        "\u{3055}\u{3099}" => "\u{3056}",  // さ + ゙ -> ざ
        "\u{3057}\u{3099}" => "\u{3058}",  // し + ゙ -> じ
        "\u{3059}\u{3099}" => "\u{305a}",  // す + ゙ -> ず
        "\u{305b}\u{3099}" => "\u{305c}",  // せ + ゙ -> ぜ
        "\u{305d}\u{3099}" => "\u{305e}",  // そ + ゙ -> ぞ
        "\u{305f}\u{3099}" => "\u{3060}",  // た + ゙ -> だ
        "\u{3061}\u{3099}" => "\u{3062}",  // ち + ゙ -> ぢ
        "\u{3064}\u{3099}" => "\u{3065}",  // つ + ゙ -> づ
        "\u{3066}\u{3099}" => "\u{3067}",  // て + ゙ -> で
        "\u{3068}\u{3099}" => "\u{3069}",  // と + ゙ -> ど
        "\u{306f}\u{3099}" => "\u{3070}",  // は + ゙ -> ば
        "\u{3072}\u{3099}" => "\u{3073}",  // ひ + ゙ -> び
        "\u{3075}\u{3099}" => "\u{3076}",  // ふ + ゙ -> ぶ
        "\u{3078}\u{3099}" => "\u{3079}",  // へ + ゙ -> べ
        "\u{307b}\u{3099}" => "\u{307c}",  // ほ + ゙ -> ぼ

        // Hiragana with handakuten (semi-voiced sound mark)
        "\u{306f}\u{309a}" => "\u{3071}",  // は + ゚ -> ぱ
        "\u{3072}\u{309a}" => "\u{3074}",  // ひ + ゚ -> ぴ
        "\u{3075}\u{309a}" => "\u{3077}",  // ふ + ゚ -> ぷ
        "\u{3078}\u{309a}" => "\u{307a}",  // へ + ゚ -> ぺ
        "\u{307b}\u{309a}" => "\u{307d}",  // ほ + ゚ -> ぽ

        // Special hiragana
        "\u{3046}\u{3099}" => "\u{3094}",  // う + ゙ -> ゔ
        "\u{309d}\u{3099}" => "\u{309e}",  // ゝ + ゙ -> ゞ

        // Katakana with dakuten
        "\u{30ab}\u{3099}" => "\u{30ac}",  // カ + ゙ -> ガ
        "\u{30ad}\u{3099}" => "\u{30ae}",  // キ + ゙ -> ギ
        "\u{30af}\u{3099}" => "\u{30b0}",  // ク + ゙ -> グ
        "\u{30b1}\u{3099}" => "\u{30b2}",  // ケ + ゙ -> ゲ
        "\u{30b3}\u{3099}" => "\u{30b4}",  // コ + ゙ -> ゴ
        "\u{30b5}\u{3099}" => "\u{30b6}",  // サ + ゙ -> ザ
        "\u{30b7}\u{3099}" => "\u{30b8}",  // シ + ゙ -> ジ
        "\u{30b9}\u{3099}" => "\u{30ba}",  // ス + ゙ -> ズ
        "\u{30bb}\u{3099}" => "\u{30bc}",  // セ + ゙ -> ゼ
        "\u{30bd}\u{3099}" => "\u{30be}",  // ソ + ゙ -> ゾ
        "\u{30bf}\u{3099}" => "\u{30c0}",  // タ + ゙ -> ダ
        "\u{30c1}\u{3099}" => "\u{30c2}",  // チ + ゙ -> ヂ
        "\u{30c4}\u{3099}" => "\u{30c5}",  // ツ + ゙ -> ヅ
        "\u{30c6}\u{3099}" => "\u{30c7}",  // テ + ゙ -> デ
        "\u{30c8}\u{3099}" => "\u{30c9}",  // ト + ゙ -> ド
        "\u{30cf}\u{3099}" => "\u{30d0}",  // ハ + ゙ -> バ
        "\u{30d2}\u{3099}" => "\u{30d3}",  // ヒ + ゙ -> ビ
        "\u{30d5}\u{3099}" => "\u{30d6}",  // フ + ゙ -> ブ
        "\u{30d8}\u{3099}" => "\u{30d9}",  // ヘ + ゙ -> ベ
        "\u{30db}\u{3099}" => "\u{30dc}",  // ホ + ゙ -> ボ

        // Katakana with handakuten
        "\u{30cf}\u{309a}" => "\u{30d1}",  // ハ + ゚ -> パ
        "\u{30d2}\u{309a}" => "\u{30d4}",  // ヒ + ゚ -> ピ
        "\u{30d5}\u{309a}" => "\u{30d7}",  // フ + ゚ -> プ
        "\u{30d8}\u{309a}" => "\u{30da}",  // ヘ + ゚ -> ペ
        "\u{30db}\u{309a}" => "\u{30dd}",  // ホ + ゚ -> ポ

        // Special katakana
        "\u{30a6}\u{3099}" => "\u{30f4}",  // ウ + ゙ -> ヴ
        "\u{30ef}\u{3099}" => "\u{30f7}",  // ワ + ゙ -> ヷ
        "\u{30f0}\u{3099}" => "\u{30f8}",  // ヰ + ゙ -> ヸ
        "\u{30f1}\u{3099}" => "\u{30f9}",  // ヱ + ゙ -> ヹ
        "\u{30f2}\u{3099}" => "\u{30fa}",  // ヲ + ゙ -> ヺ
    ];

    private bool $composeNonCombiningMarks;

    /**
     * @var array<string, array<string, string>>
     */
    private array $compositionMappings;

    /**
     * @param array<string, mixed> $options
     */
    public function __construct(array $options = [])
    {
        $this->composeNonCombiningMarks = (bool) ($options['composeNonCombiningMarks'] ?? true);
        $this->compositionMappings = $this->buildCompositionMappings();
    }

    /**
     * Build the composition mapping trie structure.
     *
     * @return array<string, array<string, string>>
     */
    private function buildCompositionMappings(): array
    {
        $mappings = [];

        foreach (self::COMPOSITION_TABLE as $decomposed => $composed) {
            $baseChar = mb_substr($decomposed, 0, 1);
            $modifier = mb_substr($decomposed, 1, 1);

            if (!isset($mappings[$baseChar])) {
                $mappings[$baseChar] = [];
            }
            $mappings[$baseChar][$modifier] = $composed;

            // If composeNonCombiningMarks is true, also handle non-combining marks
            if ($this->composeNonCombiningMarks) {
                // Convert combining marks to non-combining marks
                // ゙ (U+3099) -> ゛ (U+309B)
                // ゚ (U+309A) -> ゜ (U+309C)
                if ($modifier === "\u{3099}") { // combining voiced sound mark
                    $mappings[$baseChar]["\u{309b}"] = $composed; // non-combining voiced
                } elseif ($modifier === "\u{309a}") { // combining semi-voiced sound mark
                    $mappings[$baseChar]["\u{309c}"] = $composed; // non-combining semi-voiced
                }
            }
        }

        return $mappings;
    }

    /**
     * @param iterable<Char> $inputChars
     * @return iterable<Char>
     */
    public function __invoke(iterable $inputChars): iterable
    {
        $offset = 0;
        $prevChar = null;
        $prevMappings = null;

        foreach ($inputChars as $char) {
            // Check if we have a pending base character and this could be a modifier
            if ($prevMappings !== null && $prevChar !== null) {
                $composed = $prevMappings[$char->c] ?? null;
                if ($composed !== null) {
                    // Found a composition, yield the composed character
                    yield new Char($composed, $offset, $prevChar);
                    $offset += mb_strlen($composed);
                    $prevChar = $prevMappings = null;
                    continue;
                }

                // No composition found, yield the previous character
                yield new Char($prevChar->c, $offset, $prevChar);
                $offset += mb_strlen($prevChar->c);
                $prevChar = $prevMappings = null;
            }

            // Check if this character can be a base for composition
            $mappings = $this->compositionMappings[$char->c] ?? null;
            if ($mappings !== null) {
                // This character might be composed with the next one
                $prevChar = $char;
                $prevMappings = $mappings;
                continue;
            }

            // Regular character, just pass it through
            yield new Char($char->c, $offset, $char);
            $offset += mb_strlen($char->c);
        }

        // Handle any remaining character
        if ($prevChar !== null) {
            yield new Char($prevChar->c, $offset, $prevChar);
            $offset += mb_strlen($prevChar->c);
        }
    }
}
