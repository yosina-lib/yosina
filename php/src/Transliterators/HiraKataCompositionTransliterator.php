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
     * Voiced character mappings (base -> voiced) - generated from shared table
     * @var array<string,string>
     */
    private static array $voicedCharacters;

    /**
     * Semi-voiced character mappings (base -> semi-voiced) - generated from shared table
     * @var array<string,string>
     */
    private static array $semiVoicedCharacters;

    private bool $composeNonCombiningMarks;

    /**
     * @var array<string, array<string, string>>
     */
    private array $table;

    /**
     * Static initialization
     */
    private static function initializeStaticData(): void
    {
        if (!isset(self::$voicedCharacters)) {
            self::$voicedCharacters = HiraKataTable::generateVoicedCharacters();
            self::$semiVoicedCharacters = HiraKataTable::generateSemiVoicedCharacters();
        }
    }

    /**
     * @param array<string, mixed> $options
     */
    public function __construct(array $options = [])
    {
        self::initializeStaticData();
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
            "\u{3099}" => self::$voicedCharacters,      // combining voiced mark
            "\u{309a}" => self::$semiVoicedCharacters, // combining semi-voiced mark
        ];

        // Add non-combining marks if enabled
        if ($this->composeNonCombiningMarks) {
            $table["\u{309b}"] = self::$voicedCharacters;      // non-combining voiced mark
            $table["\u{309c}"] = self::$semiVoicedCharacters; // non-combining semi-voiced mark
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
