<?php

declare(strict_types=1);

namespace Yosina\Transliterators;

use Yosina\Char;
use Yosina\TransliteratorInterface;

/**
 * Combines decomposed hiragana and katakana characters into composed equivalents.
 *
 * This transliterator handles composition of characters like か + ゛-> が, combining
 * base characters with diacritical marks (dakuten and handakuten) into their
 * precomposed forms.
 */
class HiraKataCompositionTransliterator implements TransliteratorInterface
{
    /**
     * Voiced character mappings (base -> voiced)
     */
    private const VOICED_CHARACTERS = [
        "\u{304b}" => "\u{304c}", // か -> が
        "\u{304d}" => "\u{304e}", // き -> ぎ
        "\u{304f}" => "\u{3050}", // く -> ぐ
        "\u{3051}" => "\u{3052}", // け -> げ
        "\u{3053}" => "\u{3054}", // こ -> ご

        "\u{3055}" => "\u{3056}", // さ -> ざ
        "\u{3057}" => "\u{3058}", // し -> じ
        "\u{3059}" => "\u{305a}", // す -> ず
        "\u{305b}" => "\u{305c}", // せ -> ぜ
        "\u{305d}" => "\u{305e}", // そ -> ぞ

        "\u{305f}" => "\u{3060}", // た -> だ
        "\u{3061}" => "\u{3062}", // ち -> ぢ
        "\u{3064}" => "\u{3065}", // つ -> づ
        "\u{3066}" => "\u{3067}", // て -> で
        "\u{3068}" => "\u{3069}", // と -> ど

        "\u{306f}" => "\u{3070}", // は -> ば
        "\u{3072}" => "\u{3073}", // ひ -> び
        "\u{3075}" => "\u{3076}", // ふ -> ぶ
        "\u{3078}" => "\u{3079}", // へ -> べ
        "\u{307b}" => "\u{307c}", // ほ -> ぼ

        "\u{3046}" => "\u{3094}", // う -> ゔ
        "\u{309d}" => "\u{309e}", // ゝ -> ゞ

        // Katakana
        "\u{30ab}" => "\u{30ac}", // カ -> ガ
        "\u{30ad}" => "\u{30ae}", // キ -> ギ
        "\u{30af}" => "\u{30b0}", // ク -> グ
        "\u{30b1}" => "\u{30b2}", // ケ -> ゲ
        "\u{30b3}" => "\u{30b4}", // コ -> ゴ

        "\u{30b5}" => "\u{30b6}", // サ -> ザ
        "\u{30b7}" => "\u{30b8}", // シ -> ジ
        "\u{30b9}" => "\u{30ba}", // ス -> ズ
        "\u{30bb}" => "\u{30bc}", // セ -> ゼ
        "\u{30bd}" => "\u{30be}", // ソ -> ゾ

        "\u{30bf}" => "\u{30c0}", // タ -> ダ
        "\u{30c1}" => "\u{30c2}", // チ -> ヂ
        "\u{30c4}" => "\u{30c5}", // ツ -> ヅ
        "\u{30c6}" => "\u{30c7}", // テ -> デ
        "\u{30c8}" => "\u{30c9}", // ト -> ド

        "\u{30cf}" => "\u{30d0}", // ハ -> バ
        "\u{30d2}" => "\u{30d3}", // ヒ -> ビ
        "\u{30d5}" => "\u{30d6}", // フ -> ブ
        "\u{30d8}" => "\u{30d9}", // ヘ -> ベ
        "\u{30db}" => "\u{30dc}", // ホ -> ボ

        "\u{30a6}" => "\u{30f4}", // ウ -> ヴ
        "\u{30ef}" => "\u{30f7}", // ワ -> ヷ
        "\u{30f0}" => "\u{30f8}", // ヰ -> ヸ
        "\u{30f1}" => "\u{30f9}", // ヱ -> ヹ
        "\u{30f2}" => "\u{30fa}", // ヲ -> ヺ
        "\u{30fd}" => "\u{30fe}", // ヽ -> ヾ
    ];

    /**
     * Semi-voiced character mappings (base -> semi-voiced)
     */
    private const SEMI_VOICED_CHARACTERS = [
        "\u{306f}" => "\u{3071}", // は -> ぱ
        "\u{3072}" => "\u{3074}", // ひ -> ぴ
        "\u{3075}" => "\u{3077}", // ふ -> ぷ
        "\u{3078}" => "\u{307a}", // へ -> ぺ
        "\u{307b}" => "\u{307d}", // ほ -> ぽ

        // Katakana
        "\u{30cf}" => "\u{30d1}", // ハ -> パ
        "\u{30d2}" => "\u{30d4}", // ヒ -> ピ
        "\u{30d5}" => "\u{30d7}", // フ -> プ
        "\u{30d8}" => "\u{30da}", // ヘ -> ペ
        "\u{30db}" => "\u{30dd}", // ホ -> ポ
    ];

    private bool $composeNonCombiningMarks;

    /**
     * @var array<string, array<string, string>>
     */
    private array $table;

    /**
     * @param array<string, mixed> $options
     */
    public function __construct(array $options = [])
    {
        $this->composeNonCombiningMarks = (bool) ($options['composeNonCombiningMarks'] ?? false);
        $this->table = $this->buildTable();
    }

    /**
     * Build the lookup table from the character arrays.
     *
     * @return array<string, array<string, string>>
     */
    private function buildTable(): array
    {
        // Build voiced table
        $table = [
            "\u{3099}" => self::VOICED_CHARACTERS,      // combining voiced mark
            "\u{309a}" => self::SEMI_VOICED_CHARACTERS, // combining semi-voiced mark
        ];

        // Add non-combining marks if enabled
        if ($this->composeNonCombiningMarks) {
            $table["\u{309b}"] = self::VOICED_CHARACTERS;      // non-combining voiced mark
            $table["\u{309c}"] = self::SEMI_VOICED_CHARACTERS; // non-combining semi-voiced mark
        }

        return $table;
    }

    /**
     * @param iterable<Char> $inputChars
     * @return iterable<Char>
     */
    public function __invoke(iterable $inputChars): iterable
    {
        $offset = 0;
        $pendingChar = null;

        foreach ($inputChars as $char) {
            if ($pendingChar !== null) {
                // Check if current char is a combining mark
                $markTable = $this->table[$char->c] ?? null;
                if ($markTable !== null) {
                    $composed = $markTable[$pendingChar->c] ?? null;
                    if ($composed !== null) {
                        yield new Char($composed, $offset, $pendingChar);
                        $offset += strlen($composed);
                        $pendingChar = null;
                        continue;
                    }
                }
                // No composition, yield pending char
                yield $pendingChar->withOffset($offset);
                $offset += strlen($pendingChar->c);
            }
            $pendingChar = $char;
        }

        // Handle any remaining character
        if ($pendingChar !== null) {
            yield $pendingChar->withOffset($offset);
            $offset += strlen($pendingChar->c);
        }
    }
}
