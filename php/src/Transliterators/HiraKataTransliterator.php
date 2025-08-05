<?php

declare(strict_types=1);

namespace Yosina\Transliterators;

use Yosina\Char;
use Yosina\TransliteratorInterface;

/**
 * Converts between Hiragana and Katakana scripts.
 *
 * This transliterator can convert hiragana characters to their katakana equivalents
 * or vice versa, based on the mode specified in options.
 */
class HiraKataTransliterator implements TransliteratorInterface
{
    public const MODE_HIRA_TO_KATA = 'hira_to_kata';
    public const MODE_KATA_TO_HIRA = 'kata_to_hira';

    /**
     * @var array<string, array<string, string>>
     */
    private static array $mappingCache = [];

    /**
     * @var array<string, string>
     */
    private array $mappingTable;

    private string $mode;

    /**
     * @param array{mode?:string} $options
     */
    public function __construct(array $options = [])
    {
        $this->mode = (string) ($options['mode'] ?? self::MODE_HIRA_TO_KATA);
        $this->mappingTable = self::buildMappingTable($this->mode);
    }

    /**
     * Build the mapping table for the specified mode
     * @param string $mode
     * @return array<string, string>
     */
    private static function buildMappingTable(string $mode): array
    {
        // Check cache first
        if (isset(self::$mappingCache[$mode])) {
            return self::$mappingCache[$mode];
        }

        $mapping = [];

        // Main table mappings
        foreach (HiraKataTable::HIRAGANA_KATAKANA_TABLE as $entry) {
            $hira = $entry[0];
            $hiraVoiced = $entry[1];
            $hiraSemivoiced = $entry[2];
            $kata = $entry[3];
            $kataVoiced = $entry[4];
            $kataSemivoiced = $entry[5];

            if ($mode === self::MODE_HIRA_TO_KATA) {
                if ($hira !== '') {
                    $mapping[$hira] = $kata;
                }
                if ($hiraVoiced !== '' && $kataVoiced !== '') {
                    $mapping[$hiraVoiced] = $kataVoiced;
                }
                if ($hiraSemivoiced !== '' && $kataSemivoiced !== '') {
                    $mapping[$hiraSemivoiced] = $kataSemivoiced;
                }
            } else {
                if ($kata !== '') {
                    $mapping[$kata] = $hira;
                }
                if ($kataVoiced !== '' && $hiraVoiced !== '') {
                    $mapping[$kataVoiced] = $hiraVoiced;
                }
                if ($kataSemivoiced !== '' && $hiraSemivoiced !== '') {
                    $mapping[$kataSemivoiced] = $hiraSemivoiced;
                }
            }
        }

        // Small character mappings
        foreach (HiraKataTable::HIRAGANA_KATAKANA_SMALL_TABLE as $entry) {
            $hiraSmall = $entry[0];
            $kataSmall = $entry[1];

            if ($mode === self::MODE_HIRA_TO_KATA) {
                $mapping[$hiraSmall] = $kataSmall;
            } else {
                $mapping[$kataSmall] = $hiraSmall;
            }
        }

        // Cache the result
        self::$mappingCache[$mode] = $mapping;

        return $mapping;
    }

    /**
     * @param iterable<Char> $inputChars
     * @return iterable<Char>
     */
    public function __invoke(iterable $inputChars): iterable
    {
        $offset = 0;

        foreach ($inputChars as $char) {
            $originalChar = $char->c;

            // Check if the character needs to be converted
            if (isset($this->mappingTable[$originalChar])) {
                yield new Char(
                    c: $this->mappingTable[$originalChar],
                    offset: $offset,
                    source: $char,
                );
            } else {
                yield $char->withOffset($offset);
            }

            $offset += strlen($originalChar);
        }
    }
}
