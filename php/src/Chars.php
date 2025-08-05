<?php

declare(strict_types=1);

namespace Yosina;

class Chars
{
    /**
     * Build a character array from a string, handling IVS/SVS sequences.
     *
     * This function properly handles Ideographic Variation Sequences (IVS) and
     * Standardized Variation Sequences (SVS) by combining base characters with
     * their variation selectors into single Char objects.
     *
     * @return array<Char>
     */
    public static function buildCharArray(string $inputString): array
    {
        $result = [];
        $offset = 0;
        $prevChar = null;
        $prevCodepoint = null;

        // Convert string to array of UTF-8 characters
        $chars = mb_str_split($inputString, 1, 'UTF-8');

        foreach ($chars as $char) {
            $codepoint = mb_ord($char, 'UTF-8');

            if ($prevChar !== null && $prevCodepoint !== null) {
                // Check if current character is a variation selector
                // Variation selectors are in ranges: U+FE00-U+FE0F, U+E0100-U+E01EF
                if (($codepoint >= 0xFE00 && $codepoint <= 0xFE0F) ||
                    ($codepoint >= 0xE0100 && $codepoint <= 0xE01EF)) {
                    // Combine previous character with variation selector
                    $combinedChar = $prevChar . $char;
                    $result[] = new Char($combinedChar, $offset);
                    $offset += strlen($combinedChar);
                    $prevChar = $prevCodepoint = null;
                    continue;
                }

                // Previous character was not followed by a variation selector
                $result[] = new Char($prevChar, $offset);
                $offset += strlen($prevChar);
            }

            // Store current character for next iteration
            $prevChar = $char;
            $prevCodepoint = $codepoint;
        }

        // Handle the last character if any
        if ($prevChar !== null) {
            $result[] = new Char($prevChar, $offset);
            $offset += strlen($prevChar);
        }

        // Add sentinel empty character
        $result[] = new Char('', $offset);

        return $result;
    }

    /**
     * Convert an iterable of characters back to a string.
     *
     * This function filters out sentinel characters (empty strings) that are
     * used internally by the transliteration system.
     *
     * @param iterable<Char> $chars
     */
    public static function fromChars(iterable $chars): string
    {
        $result = '';
        foreach ($chars as $char) {
            if ($char->c !== '') {
                $result .= $char->c;
            }
        }
        return $result;
    }
}
