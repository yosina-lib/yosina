<?php

declare(strict_types=1);

namespace Yosina\Transliterators;

use Yosina\Char;
use Yosina\TransliteratorInterface;

/**
 * IVS/SVS base transliterator.
 *
 * This transliterator handles Ideographic Variation Sequences (IVS) and
 * Standardized Variation Sequences (SVS) by either adding selectors to base
 * characters or removing selectors from variant characters.
 */
class IvsSvsBaseTransliterator implements TransliteratorInterface
{
    /**
     * @var array<'unijis_90'|'unijis_2004', array<string, array{ivs: string|null, svs: string|null}>>|null
     */
    private static ?array $baseToVariants = null;
    /**
     * @var array<string, array{unijis_90: string|null, unijis_2004: string|null}>|null
     */
    private static ?array $variantsToBase = null;

    /** @var 'ivs-or-svs'|'base'  */
    private string $mode;
    /** @var 'unijis_90'|'unijis_2004' */
    private string $charset;
    private bool $dropSelectorsAltogether;
    private bool $preferSvs;

    /**
     * @param array{mode?:string,charset?:string,drop_selectors_altogether?:bool,prefer_svs?:bool} $options
     */
    public function __construct(array $options = [])
    {
        $mode = $options['mode'] ?? 'base';
        assert($mode === 'base' || $mode === 'ivs-or-svs');
        $this->mode = $mode;

        $charset = $options['charset'] ?? 'unijis_2004';
        assert($charset === 'unijis_2004' || $charset === 'unijis_90');
        $this->charset = $charset;

        $this->dropSelectorsAltogether = (bool) ($options['drop_selectors_altogether'] ?? false);
        $this->preferSvs = (bool) ($options['prefer_svs'] ?? false);
    }

    private static function loadData(): void
    {
        if (self::$baseToVariants !== null) {
            return;
        }

        $dataFile = __DIR__ . '/ivs_svs_base.data';
        if (!file_exists($dataFile)) {
            throw new \RuntimeException("IVS/SVS data file not found: {$dataFile}");
        }

        $data = file_get_contents($dataFile);
        if ($data === false) {
            throw new \RuntimeException("Failed to read IVS/SVS data file: {$dataFile}");
        }

        $baseToVariants = [
            'unijis_90' => [],
            'unijis_2004' => [],
        ];
        $variantsToBase = [];

        $offset = 0;
        $recordCountData = unpack('N', substr($data, $offset, 4));
        assert($recordCountData !== false);
        $recordCount = $recordCountData[1];
        $offset += 4;

        for ($i = 0; $i < $recordCount; $i++) {
            // Read IVS (2 ints = 8 bytes)
            $ivsCodepoints = unpack('N2', substr($data, $offset, 8));
            assert($ivsCodepoints !== false);
            $offset += 8;

            // Read SVS (2 ints = 8 bytes)
            $svsCodepoints = unpack('N2', substr($data, $offset, 8));
            assert($svsCodepoints !== false);
            $offset += 8;

            // Read base90 (1 int = 4 bytes)
            $base90Data = unpack('N', substr($data, $offset, 4));
            assert($base90Data !== false);
            $base90Codepoint = $base90Data[1];
            $offset += 4;

            // Read base2004 (1 int = 4 bytes)
            $base2004Data = unpack('N', substr($data, $offset, 4));
            assert($base2004Data !== false);
            $base2004Codepoint = $base2004Data[1];
            $offset += 4;

            // Convert to strings
            $ivs = null;
            if ($ivsCodepoints[1] !== 0) {
                $ivs = mb_chr($ivsCodepoints[1], 'UTF-8');
                if ($ivsCodepoints[2] !== 0) {
                    $ivs .= mb_chr($ivsCodepoints[2], 'UTF-8');
                }
            }

            $svs = null;
            if ($svsCodepoints[1] !== 0) {
                $svs = mb_chr($svsCodepoints[1], 'UTF-8');
                if ($svsCodepoints[2] !== 0) {
                    $svs .= mb_chr($svsCodepoints[2], 'UTF-8');
                }
            }

            $base90 = $base90Codepoint !== 0 ? mb_chr($base90Codepoint, 'UTF-8') : null;
            $base2004 = $base2004Codepoint !== 0 ? mb_chr($base2004Codepoint, 'UTF-8') : null;

            // Build mappings
            if ($base90 !== null) {
                $baseToVariants['unijis_90'][$base90] = [
                    'ivs' => $ivs,
                    'svs' => $svs,
                ];
            }

            if ($base2004 !== null) {
                $baseToVariants['unijis_2004'][$base2004] = [
                    'ivs' => $ivs,
                    'svs' => $svs,
                ];
            }

            if ($ivs !== null) {
                $variantsToBase[$ivs] = [
                    'unijis_90' => $base90,
                    'unijis_2004' => $base2004,
                ];
            }

            if ($svs !== null) {
                $variantsToBase[$svs] = [
                    'unijis_90' => $base90,
                    'unijis_2004' => $base2004,
                ];
            }
        }

        self::$baseToVariants = $baseToVariants;
        self::$variantsToBase = $variantsToBase;
    }

    /**
     * @param iterable<Char> $inputChars
     * @return iterable<Char>
     */
    public function __invoke(iterable $inputChars): iterable
    {
        if ($this->mode === 'ivs-or-svs') {
            yield from $this->forwardTransliterate($inputChars);
        } else {
            yield from $this->reverseTransliterate($inputChars);
        }
    }

    /**
     * @param iterable<Char> $inputChars
     * @return iterable<Char>
     */
    private function forwardTransliterate(iterable $inputChars): iterable
    {
        self::loadData();
        $offset = 0;

        foreach ($inputChars as $char) {
            $record = self::$baseToVariants[$this->charset][$char->c] ?? null;
            $replacement = null;

            if ($record !== null) {
                if ($this->preferSvs && $record['svs'] !== null) {
                    $replacement = $record['svs'];
                } elseif ($record['ivs'] !== null) {
                    $replacement = $record['ivs'];
                }
            }

            if ($replacement !== null) {
                yield new Char($replacement, $offset, $char);
                $offset += strlen($replacement);
            } else {
                yield $char->withOffset($offset);
                $offset += strlen($char->c);
            }
        }
    }

    /**
     * @param iterable<Char> $inputChars
     * @return iterable<Char>
     */
    private function reverseTransliterate(iterable $inputChars): iterable
    {
        self::loadData();
        $offset = 0;

        foreach ($inputChars as $char) {
            $record = self::$variantsToBase[$char->c] ?? null;
            $replacement = null;

            if ($record !== null) {
                $replacement = $record[$this->charset] ?? null;
            } elseif ($this->dropSelectorsAltogether) {
                // Remove variation selectors even if not in mapping
                $replacement = $this->removeVariationSelectors($char->c);
            }

            if ($replacement !== null && $replacement !== $char->c) {
                yield new Char($replacement, $offset, $char);
                $offset += strlen($replacement);
            } else {
                yield $char->withOffset($offset);
                $offset += strlen($char->c);
            }
        }
    }

    private function removeVariationSelectors(string $char): ?string
    {
        // Remove variation selectors (U+FE00-U+FE0F, U+E0100-U+E01EF)
        $chars = mb_str_split($char, 1, 'UTF-8');
        $result = '';
        foreach ($chars as $c) {
            $codepoint = mb_ord($c, 'UTF-8');
            if (!(($codepoint >= 0xFE00 && $codepoint <= 0xFE0F) ||
                  ($codepoint >= 0xE0100 && $codepoint <= 0xE01EF))) {
                $result .= $c;
            }
        }
        return $result !== $char ? $result : null;
    }
}
