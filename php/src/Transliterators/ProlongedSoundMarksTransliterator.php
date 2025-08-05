<?php

declare(strict_types=1);

namespace Yosina\Transliterators;

use Yosina\Char;
use Yosina\TransliteratorInterface;

/**
 * Prolonged sound marks transliterator.
 *
 * This transliterator handles the replacement of hyphen-like characters with
 * appropriate prolonged sound marks (ー or ｰ) when they appear after Japanese
 * characters that can be prolonged.
 */
class ProlongedSoundMarksTransliterator implements TransliteratorInterface
{
    // Character type classification flags
    private const OTHER = 0x00;
    private const HIRAGANA = 0x20;
    private const KATAKANA = 0x40;
    private const ALPHABET = 0x60;
    private const DIGIT = 0x80;
    private const EITHER = 0xA0;

    // Additional flags
    private const HALFWIDTH = 1 << 0;
    private const VOWEL_ENDED = 1 << 1;
    private const HATSUON = 1 << 2;
    private const SOKUON = 1 << 3;
    private const PROLONGED_SOUND_MARK = 1 << 4;

    // Combined types
    private const HALFWIDTH_DIGIT = self::DIGIT | self::HALFWIDTH;
    private const FULLWIDTH_DIGIT = self::DIGIT;
    private const HALFWIDTH_ALPHABET = self::ALPHABET | self::HALFWIDTH;
    private const FULLWIDTH_ALPHABET = self::ALPHABET;
    private const ORDINARY_HIRAGANA = self::HIRAGANA | self::VOWEL_ENDED;
    private const ORDINARY_KATAKANA = self::KATAKANA | self::VOWEL_ENDED;
    private const ORDINARY_HALFWIDTH_KATAKANA = self::KATAKANA | self::VOWEL_ENDED | self::HALFWIDTH;

    /**
     * Special character mappings
     */
    private const SPECIALS = [
        0xFF70 => self::KATAKANA | self::PROLONGED_SOUND_MARK | self::HALFWIDTH,  // ｰ
        0x30FC => self::EITHER | self::PROLONGED_SOUND_MARK,  // ー
        0x3063 => self::HIRAGANA | self::SOKUON,  // っ
        0x3093 => self::HIRAGANA | self::HATSUON,  // ん
        0x30C3 => self::KATAKANA | self::SOKUON,  // ッ
        0x30F3 => self::KATAKANA | self::HATSUON,  // ン
        0xFF6F => self::KATAKANA | self::SOKUON | self::HALFWIDTH,  // ｯ
        0xFF9D => self::KATAKANA | self::HATSUON | self::HALFWIDTH,  // ﾝ
    ];

    /**
     * Hyphen-like characters that could be prolonged sound marks
     */
    private const HYPHEN_LIKE_CHARS = [
        "\u{002d}" => true,  // -
        "\u{2010}" => true,  // ‐
        "\u{2014}" => true,  // —
        "\u{2015}" => true,  // ―
        "\u{2212}" => true,  // −
        "\u{ff0d}" => true,  // －
        "\u{ff70}" => true,  // ｰ
        "\u{30fc}" => true,  // ー
    ];

    private bool $skipAlreadyTransliteratedChars;
    private bool $allowProlongedHatsuon;
    private bool $allowProlongedSokuon;
    private bool $replaceProlongedMarksFollowingAlnums;
    private int $prolongables;

    /**
     * @param array<string, mixed> $options
     */
    public function __construct(array $options = [])
    {
        $this->skipAlreadyTransliteratedChars = (bool) ($options['skipAlreadyTransliteratedChars'] ?? false);
        $this->allowProlongedHatsuon = (bool) ($options['allowProlongedHatsuon'] ?? false);
        $this->allowProlongedSokuon = (bool) ($options['allowProlongedSokuon'] ?? false);
        $this->replaceProlongedMarksFollowingAlnums = (bool) ($options['replaceProlongedMarksFollowingAlnums'] ?? false);

        // Build prolongable character types
        $this->prolongables = self::VOWEL_ENDED | self::PROLONGED_SOUND_MARK;
        if ($this->allowProlongedHatsuon) {
            $this->prolongables |= self::HATSUON;
        }
        if ($this->allowProlongedSokuon) {
            $this->prolongables |= self::SOKUON;
        }
    }

    /**
     * Get the character type for a given Unicode codepoint.
     */
    private function getCharType(int $codepoint): int
    {
        // Halfwidth digits
        if ($codepoint >= 0x30 && $codepoint <= 0x39) {
            return self::HALFWIDTH_DIGIT;
        }

        // Fullwidth digits
        if ($codepoint >= 0xFF10 && $codepoint <= 0xFF19) {
            return self::FULLWIDTH_DIGIT;
        }

        // Halfwidth alphabets
        if (($codepoint >= 0x41 && $codepoint <= 0x5A) || ($codepoint >= 0x61 && $codepoint <= 0x7A)) {
            return self::HALFWIDTH_ALPHABET;
        }

        // Fullwidth alphabets
        if (($codepoint >= 0xFF21 && $codepoint <= 0xFF3A) || ($codepoint >= 0xFF41 && $codepoint <= 0xFF5A)) {
            return self::FULLWIDTH_ALPHABET;
        }

        // Special characters
        if (isset(self::SPECIALS[$codepoint])) {
            return self::SPECIALS[$codepoint];
        }

        // Hiragana
        if (($codepoint >= 0x3041 && $codepoint <= 0x309C) || $codepoint === 0x309F) {
            return self::ORDINARY_HIRAGANA;
        }

        // Katakana
        if (($codepoint >= 0x30A1 && $codepoint <= 0x30FA) || ($codepoint >= 0x30FD && $codepoint <= 0x30FF)) {
            return self::ORDINARY_KATAKANA;
        }

        // Halfwidth katakana
        if (($codepoint >= 0xFF66 && $codepoint <= 0xFF6F) || ($codepoint >= 0xFF71 && $codepoint <= 0xFF9F)) {
            return self::ORDINARY_HALFWIDTH_KATAKANA;
        }

        return self::OTHER;
    }

    /**
     * Check if character type is alphanumeric.
     */
    private function isAlnum(int $charType): bool
    {
        $masked = $charType & 0xE0;
        return $masked === self::ALPHABET || $masked === self::DIGIT;
    }

    /**
     * Check if character type is halfwidth.
     */
    private function isHalfwidth(int $charType): bool
    {
        return ($charType & self::HALFWIDTH) !== 0;
    }

    /**
     * Check if character is hyphen-like.
     */
    private function isHyphenLike(string $char): bool
    {
        return isset(self::HYPHEN_LIKE_CHARS[$char]);
    }

    /**
     * @param iterable<Char> $inputChars
     * @return iterable<Char>
     */
    public function __invoke(iterable $inputChars): iterable
    {
        $offset = 0;
        $processedCharsInLookahead = false;
        $lookaheadBuf = [];
        $lastNonProlongedChar = null;

        foreach ($inputChars as $char) {
            if (!empty($lookaheadBuf)) {
                if ($this->isHyphenLike($char->c)) {
                    if ($char->source !== null) {
                        $processedCharsInLookahead = true;
                    }
                    $lookaheadBuf[] = $char;
                    continue;
                }

                // Process buffered characters
                $prevNonProlongedChar = $lastNonProlongedChar;
                $firstChar = mb_substr($char->c, 0, 1, 'UTF-8');
                $codepoint = $firstChar !== '' ? mb_ord($firstChar, 'UTF-8') : -1;
                $lastNonProlongedChar = [$char, $this->getCharType($codepoint)];

                // Check if we should replace with hyphens for alphanumerics
                if (($prevNonProlongedChar === null || $this->isAlnum($prevNonProlongedChar[1])) &&
                    (!$this->skipAlreadyTransliteratedChars || !$processedCharsInLookahead)) {

                    $replacement = ($prevNonProlongedChar === null
                                    ? $this->isHalfwidth($lastNonProlongedChar[1])
                                    : $this->isHalfwidth($prevNonProlongedChar[1]))
                        ? "\u{002d}"
                        : "\u{ff0d}";

                    foreach ($lookaheadBuf as $bufferedChar) {
                        yield new Char($replacement, $offset, $bufferedChar);
                        $offset += strlen($replacement);
                    }
                } else {
                    // Just pass through the buffered characters
                    foreach ($lookaheadBuf as $bufferedChar) {
                        yield $bufferedChar->withOffset($offset);
                        $offset += strlen($bufferedChar->c);
                    }
                }

                $lookaheadBuf = [];
                yield $char->withOffset($offset);
                $offset += strlen($char->c);
                $processedCharsInLookahead = false;
                continue;
            }

            // Check if this is a hyphen-like character that might be a prolonged sound mark
            if ($this->isHyphenLike($char->c)) {
                $shouldProcess = !$this->skipAlreadyTransliteratedChars || !$char->isTransliterated();
                if ($shouldProcess && $lastNonProlongedChar !== null) {
                    if (($this->prolongables & $lastNonProlongedChar[1]) !== 0) {
                        $replacement = $this->isHalfwidth($lastNonProlongedChar[1]) ? "\u{ff70}" : "\u{30fc}";
                        yield new Char($replacement, $offset, $char);
                        $offset += strlen($replacement);
                        continue;
                    } else {
                        // Check if we should buffer for alphanumeric replacement
                        if ($this->replaceProlongedMarksFollowingAlnums && $this->isAlnum($lastNonProlongedChar[1])) {
                            $lookaheadBuf[] = $char;
                            continue;
                        }
                    }
                }
            } else {
                // Update last non-prolonged character ONLY for non-hyphen characters
                $firstChar = mb_substr($char->c, 0, 1, 'UTF-8');
                $codepoint = $firstChar !== '' ? mb_ord($firstChar, 'UTF-8') : -1;
                $lastNonProlongedChar = [$char, $this->getCharType($codepoint)];
            }

            // Default: pass through the character
            yield $char->withOffset($offset);
            $offset += strlen($char->c);
        }
    }
}
