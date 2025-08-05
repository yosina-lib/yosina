<?php

declare(strict_types=1);

namespace Yosina\Transliterators;

use Yosina\Char;
use Yosina\TransliteratorInterface;

/**
 * Japanese iteration marks transliterator.
 *
 * This transliterator handles the replacement of Japanese iteration marks
 * with the appropriate repeated characters:
 * - ゝ (hiragana repetition): Repeats previous hiragana if valid
 * - ゞ (hiragana voiced repetition): Repeats previous hiragana with voicing if possible
 * - ヽ (katakana repetition): Repeats previous katakana if valid
 * - ヾ (katakana voiced repetition): Repeats previous katakana with voicing if possible
 * - 々 (kanji repetition): Repeats previous kanji
 *
 * Invalid combinations remain unchanged. Characters that can't be repeated include:
 * - Voiced/semi-voiced characters
 * - Hatsuon (ん/ン)
 * - Sokuon (っ/ッ)
 *
 * Halfwidth katakana with iteration marks are NOT supported.
 * Consecutive iteration marks: only the first one is expanded.
 */
class JapaneseIterationMarksTransliterator implements TransliteratorInterface
{
    // Iteration mark characters
    private const HIRAGANA_ITERATION_MARK = "\u{309d}"; // ゝ
    private const HIRAGANA_VOICED_ITERATION_MARK = "\u{309e}"; // ゞ
    private const KATAKANA_ITERATION_MARK = "\u{30fd}"; // ヽ
    private const KATAKANA_VOICED_ITERATION_MARK = "\u{30fe}"; // ヾ
    private const KANJI_ITERATION_MARK = "\u{3005}"; // 々

    // Character type constants
    private const TYPE_OTHER = 0;
    private const TYPE_HIRAGANA = 1;
    private const TYPE_KATAKANA = 2;
    private const TYPE_KANJI = 3;

    // Special characters that cannot be repeated
    private const HATSUON_CHARS = [
        0x3093 => true, // ん
        0x30F3 => true, // ン
        0xFF9D => true, // ﾝ (halfwidth)
    ];

    private const SOKUON_CHARS = [
        0x3063 => true, // っ
        0x30C3 => true, // ッ
        0xFF6F => true, // ｯ (halfwidth)
    ];

    // Semi-voiced characters
    private const SEMI_VOICED_CHARS = [
        // Hiragana semi-voiced
        'ぱ' => true, 'ぴ' => true, 'ぷ' => true, 'ぺ' => true, 'ぽ' => true,
        // Katakana semi-voiced
        'パ' => true, 'ピ' => true, 'プ' => true, 'ペ' => true, 'ポ' => true,
    ];

    // Voicing mappings for hiragana
    private const HIRAGANA_VOICING = [
        'か' => 'が', 'き' => 'ぎ', 'く' => 'ぐ', 'け' => 'げ', 'こ' => 'ご',
        'さ' => 'ざ', 'し' => 'じ', 'す' => 'ず', 'せ' => 'ぜ', 'そ' => 'ぞ',
        'た' => 'だ', 'ち' => 'ぢ', 'つ' => 'づ', 'て' => 'で', 'と' => 'ど',
        'は' => 'ば', 'ひ' => 'び', 'ふ' => 'ぶ', 'へ' => 'べ', 'ほ' => 'ぼ',
    ];

    // Voicing mappings for katakana
    private const KATAKANA_VOICING = [
        'カ' => 'ガ', 'キ' => 'ギ', 'ク' => 'グ', 'ケ' => 'ゲ', 'コ' => 'ゴ',
        'サ' => 'ザ', 'シ' => 'ジ', 'ス' => 'ズ', 'セ' => 'ゼ', 'ソ' => 'ゾ',
        'タ' => 'ダ', 'チ' => 'ヂ', 'ツ' => 'ヅ', 'テ' => 'デ', 'ト' => 'ド',
        'ハ' => 'バ', 'ヒ' => 'ビ', 'フ' => 'ブ', 'ヘ' => 'ベ', 'ホ' => 'ボ',
        'ウ' => 'ヴ',
    ];

    /**
     * @param array<string, mixed> $options Currently unused but kept for consistency
     */
    public function __construct(/* @phpstan-ignore constructor.unusedParameter */ array $options = [])
    {
        // Options reserved for future use
    }

    /**
     * Check if a character is an iteration mark.
     */
    private function isIterationMark(string $char): bool
    {
        return in_array($char, [
            self::HIRAGANA_ITERATION_MARK,
            self::HIRAGANA_VOICED_ITERATION_MARK,
            self::KATAKANA_ITERATION_MARK,
            self::KATAKANA_VOICED_ITERATION_MARK,
            self::KANJI_ITERATION_MARK,
        ], true);
    }

    /**
     * Get the character type for a given character.
     */
    private function getCharType(string $char): int
    {
        if (mb_strlen($char, 'UTF-8') === 0) {
            return self::TYPE_OTHER;
        }

        $codepoint = mb_ord($char, 'UTF-8');

        // Check if it's hatsuon or sokuon
        if (isset(self::HATSUON_CHARS[$codepoint]) || isset(self::SOKUON_CHARS[$codepoint])) {
            return self::TYPE_OTHER;
        }

        // Check if it's voiced or semi-voiced
        if (in_array($char, self::HIRAGANA_VOICING, true) || in_array($char, self::KATAKANA_VOICING, true) || isset(self::SEMI_VOICED_CHARS[$char])) {
            return self::TYPE_OTHER;
        }

        // Hiragana (excluding special marks)
        if ($codepoint >= 0x3041 && $codepoint <= 0x3096) {
            return self::TYPE_HIRAGANA;
        }

        // Katakana (excluding halfwidth and special marks)
        if ($codepoint >= 0x30A1 && $codepoint <= 0x30FA) {
            return self::TYPE_KATAKANA;
        }

        // Kanji - CJK Unified Ideographs (common ranges)
        if (($codepoint >= 0x4E00 && $codepoint <= 0x9FFF) ||
            ($codepoint >= 0x3400 && $codepoint <= 0x4DBF) ||
            ($codepoint >= 0x20000 && $codepoint <= 0x2A6DF) ||
            ($codepoint >= 0x2A700 && $codepoint <= 0x2B73F) ||
            ($codepoint >= 0x2B740 && $codepoint <= 0x2B81F) ||
            ($codepoint >= 0x2B820 && $codepoint <= 0x2CEAF) ||
            ($codepoint >= 0x2CEB0 && $codepoint <= 0x2EBEF) ||
            ($codepoint >= 0x30000 && $codepoint <= 0x3134F)) {
            return self::TYPE_KANJI;
        }

        return self::TYPE_OTHER;
    }

    /**
     * @param iterable<Char> $inputChars
     * @return iterable<Char>
     */
    public function __invoke(iterable $inputChars): iterable
    {
        $offset = 0;
        $prevCharInfo = null;
        $prevWasIterationMark = false;

        foreach ($inputChars as $char) {
            $currentChar = $char->c;

            if ($this->isIterationMark($currentChar)) {
                // Check if previous character was also an iteration mark
                if ($prevWasIterationMark) {
                    // Don't replace consecutive iteration marks
                    yield $char->withOffset($offset);
                    $offset += strlen($currentChar);
                    $prevWasIterationMark = true;
                    continue;
                }

                // Try to replace the iteration mark
                $replacement = null;
                if ($prevCharInfo !== null) {
                    switch ($currentChar) {
                        case self::HIRAGANA_ITERATION_MARK:
                            // Repeat previous hiragana if valid
                            if ($prevCharInfo['type'] === self::TYPE_HIRAGANA) {
                                $replacement = $prevCharInfo['char'];
                            }
                            break;

                        case self::HIRAGANA_VOICED_ITERATION_MARK:
                            // Repeat previous hiragana with voicing if possible
                            if ($prevCharInfo['type'] === self::TYPE_HIRAGANA) {
                                $replacement = self::HIRAGANA_VOICING[$prevCharInfo['char']] ?? null;
                            }
                            break;

                        case self::KATAKANA_ITERATION_MARK:
                            // Repeat previous katakana if valid
                            if ($prevCharInfo['type'] === self::TYPE_KATAKANA) {
                                $replacement = $prevCharInfo['char'];
                            }
                            break;

                        case self::KATAKANA_VOICED_ITERATION_MARK:
                            // Repeat previous katakana with voicing if possible
                            if ($prevCharInfo['type'] === self::TYPE_KATAKANA) {
                                $replacement = self::KATAKANA_VOICING[$prevCharInfo['char']] ?? null;
                            }
                            break;

                        case self::KANJI_ITERATION_MARK:
                            // Repeat previous kanji
                            if ($prevCharInfo['type'] === self::TYPE_KANJI) {
                                $replacement = $prevCharInfo['char'];
                            }
                            break;
                    }
                }

                if ($replacement !== null) {
                    // Replace the iteration mark
                    yield new Char($replacement, $offset, $char);
                    $offset += strlen($replacement);
                    $prevWasIterationMark = true;
                    // Keep the original prevCharInfo - don't update it
                } else {
                    // Couldn't replace the iteration mark
                    yield $char->withOffset($offset);
                    $offset += strlen($currentChar);
                    $prevWasIterationMark = true;
                }
            } else {
                // Not an iteration mark
                yield $char->withOffset($offset);
                $offset += strlen($currentChar);

                // Update previous character info
                $charType = $this->getCharType($currentChar);
                if ($charType !== self::TYPE_OTHER) {
                    $prevCharInfo = ['char' => $currentChar, 'type' => $charType];
                } else {
                    $prevCharInfo = null;
                }

                $prevWasIterationMark = false;
            }
        }
    }
}
