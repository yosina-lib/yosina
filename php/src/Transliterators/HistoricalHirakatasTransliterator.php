<?php

declare(strict_types=1);

namespace Yosina\Transliterators;

use Yosina\Char;
use Yosina\TransliteratorInterface;

/**
 * Converts historical hiragana/katakana characters to their modern equivalents.
 *
 * Handles three categories of historical kana:
 * - Historical hiragana: ゐ (U+3090) and ゑ (U+3091)
 * - Historical katakana: ヰ (U+30F0) and ヱ (U+30F1)
 * - Voiced historical katakana: ヷ (U+30F7), ヸ (U+30F8), ヹ (U+30F9), ヺ (U+30FA)
 */
class HistoricalHirakatasTransliterator implements TransliteratorInterface
{
    private const CONVERT_SIMPLE = 'simple';
    private const CONVERT_DECOMPOSE = 'decompose';
    private const CONVERT_SKIP = 'skip';

    /**
     * Mappings for historical hiragana.
     * Each entry: source => [simple replacement, decomposed replacement (array of chars)]
     * @var array<string, array{simple: string, decompose: list<string>}>
     */
    private const HISTORICAL_HIRAGANA = [
        "\u{3090}" => ['simple' => "\u{3044}", 'decompose' => ["\u{3046}", "\u{3043}"]], // ゐ → い / うぃ
        "\u{3091}" => ['simple' => "\u{3048}", 'decompose' => ["\u{3046}", "\u{3047}"]], // ゑ → え / うぇ
    ];

    /**
     * Mappings for historical katakana.
     * @var array<string, array{simple: string, decompose: list<string>}>
     */
    private const HISTORICAL_KATAKANA = [
        "\u{30F0}" => ['simple' => "\u{30A4}", 'decompose' => ["\u{30A6}", "\u{30A3}"]], // ヰ → イ / ウィ
        "\u{30F1}" => ['simple' => "\u{30A8}", 'decompose' => ["\u{30A6}", "\u{30A7}"]], // ヱ → エ / ウェ
    ];

    /**
     * Mappings for voiced historical katakana (decompose only).
     * @var array<string, string>
     */
    private const VOICED_HISTORICAL_KANA = [
        "\u{30F7}" => "\u{30A1}", // ヷ → ァ
        "\u{30F8}" => "\u{30A3}", // ヸ → ィ
        "\u{30F9}" => "\u{30A7}", // ヹ → ェ
        "\u{30FA}" => "\u{30A9}", // ヺ → ォ
    ];

    /**
     * Decomposed voiced historical kana mappings (for decomposed input → decomposed output).
     * @var array<string, string>
     */
    private const VOICED_HISTORICAL_KANA_DECOMPOSED = [
        "\u{30EF}" => "\u{30A1}", // ヷ → ァ
        "\u{30F0}" => "\u{30A3}", // ヸ → ィ
        "\u{30F1}" => "\u{30A7}", // ヹ → ェ
        "\u{30F2}" => "\u{30A9}", // ヺ → ォ
    ];


    private const COMBINING_DAKUTEN = "\u{3099}";
    private const VU = "\u{30F4}";
    private const U = "\u{30A6}";

    private string $hiraganas;
    private string $katakanas;
    private string $voicedKatakanas;

    /**
     * @param array{hiraganas?: string, katakanas?: string, voicedKatakanas?: string} $options
     */
    public function __construct(array $options = [])
    {
        $this->hiraganas = $options['hiraganas'] ?? self::CONVERT_SIMPLE;
        $this->katakanas = $options['katakanas'] ?? self::CONVERT_SIMPLE;
        $this->voicedKatakanas = $options['voicedKatakanas'] ?? self::CONVERT_SKIP;
    }

    /**
     * @param iterable<Char> $inputChars
     * @return iterable<Char>
     */
    public function __invoke(iterable $inputChars): iterable
    {
        $offset = 0;
        $pending = null;

        foreach ($inputChars as $char) {
            if ($pending === null) {
                $pending = $char;
                continue;
            }
            if ($char->c === self::COMBINING_DAKUTEN) {
                // Check if current char could be a decomposed voiced base
                $decomposed = self::VOICED_HISTORICAL_KANA_DECOMPOSED[$pending->c] ?? null;
                if ($this->voicedKatakanas === self::CONVERT_SKIP || !isset($decomposed)) {
                    yield $pending->withOffset($offset);
                    $offset += strlen($pending->c);
                    $pending = $char;
                    continue;
                }
                yield new Char(self::U, $offset, $pending);
                $offset += strlen(self::U);
                yield $char->withOffset($offset);
                $offset += strlen($char->c);
                yield new Char($decomposed, $offset, $pending);
                $offset += strlen($decomposed);
                $pending = null;
                continue;
            }
            yield from $this->processChar($pending, $offset);
            $pending = $char;
        }

        // Flush remaining pending char
        if ($pending !== null) {
            yield from $this->processChar($pending, $offset);
        }
    }

    /**
     * Process a single char through the normal transliteration logic.
     *
     * @param Char $char
     * @param int &$offset
     * @return iterable<Char>
     */
    private function processChar(Char $char, int &$offset): iterable
    {
        // Check historical hiragana
        if ($this->hiraganas !== self::CONVERT_SKIP) {
            $record = self::HISTORICAL_HIRAGANA[$char->c] ?? null;
            if ($record !== null) {
                yield from $this->emitReplacement($char, $record, $this->hiraganas, $offset);
                return;
            }
        }

        // Check historical katakana
        if ($this->katakanas !== self::CONVERT_SKIP) {
            $record = self::HISTORICAL_KATAKANA[$char->c] ?? null;
            if ($record !== null) {
                yield from $this->emitReplacement($char, $record, $this->katakanas, $offset);
                return;
            }
        }

        // Check voiced historical kana (precomposed)
        if ($this->voicedKatakanas !== self::CONVERT_SKIP) {
            $decomposed = self::VOICED_HISTORICAL_KANA[$char->c] ?? null;
            if ($decomposed !== null) {
                yield new Char(self::VU, $offset, $char);
                $offset += strlen(self::VU);
                yield new Char($decomposed, $offset, $char);
                $offset += strlen($decomposed);
                return;
            }
        }

        yield $char->withOffset($offset);
        $offset += strlen($char->c);
    }

    /**
     * @param Char $char
     * @param array{simple: string, decompose: list<string>} $record
     * @param string $mode
     * @param int &$offset
     * @return iterable<Char>
     */
    private function emitReplacement(Char $char, array $record, string $mode, int &$offset): iterable
    {
        if ($mode === self::CONVERT_DECOMPOSE) {
            foreach ($record['decompose'] as $replacementChar) {
                yield new Char($replacementChar, $offset, $char);
                $offset += strlen($replacementChar);
            }
        } else {
            // simple mode
            $replacement = $record['simple'];
            yield new Char($replacement, $offset, $char);
            $offset += strlen($replacement);
        }
    }
}
