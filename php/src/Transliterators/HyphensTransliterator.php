<?php

declare(strict_types=1);

namespace Yosina\Transliterators;

use Yosina\Char;
use Yosina\TransliteratorInterface;

/**
 * Hyphen character normalization transliterator.
 *
 * This transliterator substitutes commoner counterparts for hyphens and a number of symbols.
 * It handles various dash/hyphen symbols and normalizes them to those common in Japanese
 * writing based on the precedence order.
 */
class HyphensTransliterator implements TransliteratorInterface
{
    private const DEFAULT_PRECEDENCE = ['jisx0208_90'];

    private const MAPPINGS = [
        "-" => [
            'ascii' => "-",
            'jisx0201' => "-",
            'jisx0208_90' => "\u{2212}",
            'jisx0208_90_windows' => "\u{2212}",
            'jisx0208_verbatim' => null,
        ],
        "|" => [
            'ascii' => "|",
            'jisx0201' => "|",
            'jisx0208_90' => "\u{FF5C}",
            'jisx0208_90_windows' => "\u{FF5C}",
            'jisx0208_verbatim' => null,
        ],
        "~" => [
            'ascii' => "~",
            'jisx0201' => "~",
            'jisx0208_90' => "\u{301C}",
            'jisx0208_90_windows' => "\u{FF5E}",
            'jisx0208_verbatim' => null,
        ],
        "\u{A2}" => [
            'ascii' => null,
            'jisx0201' => null,
            'jisx0208_90' => "\u{A2}",
            'jisx0208_90_windows' => "\u{FFE0}",
            'jisx0208_verbatim' => "\u{A2}",
        ],
        "\u{A3}" => [
            'ascii' => null,
            'jisx0201' => null,
            'jisx0208_90' => "\u{A3}",
            'jisx0208_90_windows' => "\u{FFE1}",
            'jisx0208_verbatim' => "\u{A3}",
        ],
        "\u{A6}" => [
            'ascii' => "|",
            'jisx0201' => "|",
            'jisx0208_90' => "\u{FF5C}",
            'jisx0208_90_windows' => "\u{FF5C}",
            'jisx0208_verbatim' => "\u{A6}",
        ],
        "\u{2D7}" => [
            'ascii' => "-",
            'jisx0201' => "-",
            'jisx0208_90' => "\u{2212}",
            'jisx0208_90_windows' => "\u{FF0D}",
            'jisx0208_verbatim' => null,
        ],
        "\u{2010}" => [
            'ascii' => "-",
            'jisx0201' => "-",
            'jisx0208_90' => "\u{2010}",
            'jisx0208_90_windows' => "\u{2010}",
            'jisx0208_verbatim' => "\u{2010}",
        ],
        "\u{2011}" => [
            'ascii' => "-",
            'jisx0201' => "-",
            'jisx0208_90' => "\u{2010}",
            'jisx0208_90_windows' => "\u{2010}",
            'jisx0208_verbatim' => null,
        ],
        "\u{2012}" => [
            'ascii' => "-",
            'jisx0201' => "-",
            'jisx0208_90' => "\u{2015}",
            'jisx0208_90_windows' => "\u{2015}",
            'jisx0208_verbatim' => null,
        ],
        "\u{2013}" => [
            'ascii' => "-",
            'jisx0201' => "-",
            'jisx0208_90' => "\u{2015}",
            'jisx0208_90_windows' => "\u{2015}",
            'jisx0208_verbatim' => "\u{2013}",
        ],
        "\u{2014}" => [
            'ascii' => "-",
            'jisx0201' => "-",
            'jisx0208_90' => "\u{2014}",
            'jisx0208_90_windows' => "\u{2015}",
            'jisx0208_verbatim' => "\u{2014}",
        ],
        "\u{2015}" => [
            'ascii' => "-",
            'jisx0201' => "-",
            'jisx0208_90' => "\u{2015}",
            'jisx0208_90_windows' => "\u{2015}",
            'jisx0208_verbatim' => "\u{2015}",
        ],
        "\u{2016}" => [
            'ascii' => null,
            'jisx0201' => null,
            'jisx0208_90' => "\u{2016}",
            'jisx0208_90_windows' => "\u{2225}",
            'jisx0208_verbatim' => "\u{2016}",
        ],
        "\u{203E}" => [
            'ascii' => null,
            'jisx0201' => "~",
            'jisx0208_90' => "\u{FFE3}",
            'jisx0208_90_windows' => "\u{FFE3}",
            'jisx0208_verbatim' => "\u{203D}",
        ],
        "\u{2043}" => [
            'ascii' => "-",
            'jisx0201' => "-",
            'jisx0208_90' => "\u{2010}",
            'jisx0208_90_windows' => "\u{2010}",
            'jisx0208_verbatim' => null,
        ],
        "\u{2053}" => [
            'ascii' => "~",
            'jisx0201' => "~",
            'jisx0208_90' => "\u{301C}",
            'jisx0208_90_windows' => "\u{301C}",
            'jisx0208_verbatim' => null,
        ],
        "\u{2212}" => [
            'ascii' => "-",
            'jisx0201' => "-",
            'jisx0208_90' => "\u{2212}",
            'jisx0208_90_windows' => "\u{FF0D}",
            'jisx0208_verbatim' => "\u{2212}",
        ],
        "\u{2225}" => [
            'ascii' => null,
            'jisx0201' => null,
            'jisx0208_90' => "\u{2016}",
            'jisx0208_90_windows' => "\u{2225}",
            'jisx0208_verbatim' => "\u{2225}",
        ],
        "\u{223C}" => [
            'ascii' => "~",
            'jisx0201' => "~",
            'jisx0208_90' => "\u{301C}",
            'jisx0208_90_windows' => "\u{FF5E}",
            'jisx0208_verbatim' => null,
        ],
        "\u{223D}" => [
            'ascii' => "~",
            'jisx0201' => "~",
            'jisx0208_90' => "\u{301C}",
            'jisx0208_90_windows' => "\u{FF5E}",
            'jisx0208_verbatim' => null,
        ],
        "\u{2500}" => [
            'ascii' => "-",
            'jisx0201' => "-",
            'jisx0208_90' => "\u{2015}",
            'jisx0208_90_windows' => "\u{2015}",
            'jisx0208_verbatim' => "\u{2500}",
        ],
        "\u{2501}" => [
            'ascii' => "-",
            'jisx0201' => "-",
            'jisx0208_90' => "\u{2015}",
            'jisx0208_90_windows' => "\u{2015}",
            'jisx0208_verbatim' => "\u{2501}",
        ],
        "\u{2502}" => [
            'ascii' => "|",
            'jisx0201' => "|",
            'jisx0208_90' => "\u{FF5C}",
            'jisx0208_90_windows' => "\u{FF5C}",
            'jisx0208_verbatim' => "\u{2502}",
        ],
        "\u{2796}" => [
            'ascii' => "-",
            'jisx0201' => "-",
            'jisx0208_90' => "\u{2212}",
            'jisx0208_90_windows' => "\u{FF0D}",
            'jisx0208_verbatim' => null,
        ],
        "\u{29FF}" => [
            'ascii' => "-",
            'jisx0201' => "-",
            'jisx0208_90' => "\u{2010}",
            'jisx0208_90_windows' => "\u{FF0D}",
            'jisx0208_verbatim' => null,
        ],
        "\u{2E3A}" => [
            'ascii' => "-",
            'jisx0201' => "-",
            'jisx0208_90' => "\u{2014}",
            'jisx0208_90_windows' => "\u{2015}",
            'jisx0208_verbatim' => null,
        ],
        "\u{2E3B}" => [
            'ascii' => "-",
            'jisx0201' => "-",
            'jisx0208_90' => "\u{2014}",
            'jisx0208_90_windows' => "\u{2015}",
            'jisx0208_verbatim' => null,
        ],
        "\u{301C}" => [
            'ascii' => "~",
            'jisx0201' => "~",
            'jisx0208_90' => "\u{301C}",
            'jisx0208_90_windows' => "\u{FF5E}",
            'jisx0208_verbatim' => "\u{301C}",
        ],
        "\u{30A0}" => [
            'ascii' => "=",
            'jisx0201' => "=",
            'jisx0208_90' => "\u{FF1D}",
            'jisx0208_90_windows' => "\u{FF1D}",
            'jisx0208_verbatim' => "\u{30A0}",
        ],
        "\u{30FB}" => [
            'ascii' => null,
            'jisx0201' => "\u{FF65}",
            'jisx0208_90' => "\u{30FB}",
            'jisx0208_90_windows' => "\u{30FB}",
            'jisx0208_verbatim' => "\u{30FB}",
        ],
        "\u{30FC}" => [
            'ascii' => "-",
            'jisx0201' => "-",
            'jisx0208_90' => "\u{30FC}",
            'jisx0208_90_windows' => "\u{30FC}",
            'jisx0208_verbatim' => "\u{30FC}",
        ],
        "\u{FE31}" => [
            'ascii' => "|",
            'jisx0201' => "|",
            'jisx0208_90' => "\u{FF5C}",
            'jisx0208_90_windows' => "\u{FF5C}",
            'jisx0208_verbatim' => null,
        ],
        "\u{FE58}" => [
            'ascii' => "-",
            'jisx0201' => "-",
            'jisx0208_90' => "\u{2010}",
            'jisx0208_90_windows' => "\u{2010}",
            'jisx0208_verbatim' => null,
        ],
        "\u{FE63}" => [
            'ascii' => "-",
            'jisx0201' => "-",
            'jisx0208_90' => "\u{2010}",
            'jisx0208_90_windows' => "\u{2010}",
            'jisx0208_verbatim' => null,
        ],
        "\u{FF02}" => [
            'ascii' => "\"",
            'jisx0201' => "\"",
            'jisx0208_90' => "\u{2033}",
            'jisx0208_90_windows' => "\u{FF02}",
            'jisx0208_verbatim' => null,
        ],
        "\u{FF07}" => [
            'ascii' => "'",
            'jisx0201' => "'",
            'jisx0208_90' => "\u{2032}",
            'jisx0208_90_windows' => "\u{FF07}",
            'jisx0208_verbatim' => null,
        ],
        "\u{FF0D}" => [
            'ascii' => "-",
            'jisx0201' => "-",
            'jisx0208_90' => "\u{2212}",
            'jisx0208_90_windows' => "\u{FF0D}",
            'jisx0208_verbatim' => null,
        ],
        "\u{FF5C}" => [
            'ascii' => "|",
            'jisx0201' => "|",
            'jisx0208_90' => "\u{FF5C}",
            'jisx0208_90_windows' => "\u{FF5C}",
            'jisx0208_verbatim' => "\u{FF5C}",
        ],
        "\u{FF5E}" => [
            'ascii' => "~",
            'jisx0201' => "~",
            'jisx0208_90' => "\u{301C}",
            'jisx0208_90_windows' => "\u{FF5E}",
            'jisx0208_verbatim' => null,
        ],
        "\u{FFE4}" => [
            'ascii' => "|",
            'jisx0201' => "|",
            'jisx0208_90' => "\u{FF5C}",
            'jisx0208_90_windows' => "\u{FFE4}",
            'jisx0208_verbatim' => "\u{FFE4}",
        ],
        "\u{FF70}" => [
            'ascii' => "-",
            'jisx0201' => "\u{FF70}",
            'jisx0208_90' => "\u{30FC}",
            'jisx0208_90_windows' => "\u{30FC}",
            'jisx0208_verbatim' => null,
        ],
        "\u{FFE8}" => [
            'ascii' => "|",
            'jisx0201' => "|",
            'jisx0208_90' => "\u{FF5C}",
            'jisx0208_90_windows' => "\u{FF5C}",
            'jisx0208_verbatim' => null,
        ],
    ];

    /**
     * @var array<int, string>
     */
    private array $precedence;

    /**
     * @param array<string, mixed> $options
     */
    public function __construct(array $options = [])
    {
        $precedence = $options['precedence'] ?? self::DEFAULT_PRECEDENCE;
        $this->precedence = is_array($precedence) ? $precedence : self::DEFAULT_PRECEDENCE;
    }

    /**
     * @param iterable<Char> $inputChars
     * @return iterable<Char>
     */
    public function __invoke(iterable $inputChars): iterable
    {
        $offset = 0;
        foreach ($inputChars as $char) {
            $record = self::MAPPINGS[$char->c] ?? null;
            if ($record !== null) {
                $replacement = $this->getReplacement($record);
                if ($replacement !== null && $replacement !== $char->c) {
                    yield new Char($replacement, $offset, $char);
                    $offset += strlen($replacement);
                } else {
                    yield $char->withOffset($offset);
                    $offset += strlen($char->c);
                }
            } else {
                yield $char;
            }
        }
    }

    /**
     * @param array<string, string|null> $record
     */
    private function getReplacement(array $record): ?string
    {
        foreach ($this->precedence as $mappingType) {
            $replacement = $record[$mappingType] ?? null;
            if ($replacement !== null) {
                return $replacement;
            }
        }
        return null;
    }
}
