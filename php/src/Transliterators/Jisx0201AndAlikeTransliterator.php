<?php

declare(strict_types=1);

namespace Yosina\Transliterators;

use Yosina\Char;
use Yosina\TransliteratorInterface;

/**
 * JIS X 0201 and alike transliterator for fullwidth/halfwidth conversion.
 *
 * This transliterator handles conversion between:
 * - Half-width group:
 *   - Alphabets, numerics, and symbols: U+0020 - U+007E, U+00A5, and U+203E.
 *   - Half-width katakanas: U+FF61 - U+FF9F.
 * - Full-width group:
 *   - Full-width alphabets, numerics, and symbols: U+FF01 - U+FF5E, U+FFE3, and U+FFE5.
 *   - Wave dash: U+301C.
 *   - Hiraganas: U+3041 - U+3094.
 *   - Katakanas: U+30A1 - U+30F7 and U+30FA.
 *   - Hiragana/katakana voicing marks: U+309B, U+309C, and U+30FC.
 *   - Japanese punctuations: U+3001, U+3002, U+30A0, and U+30FB.
 */
class Jisx0201AndAlikeTransliterator implements TransliteratorInterface
{
    /** @var array<string,string> GL area mapping table (fullwidth to halfwidth) */
    private const JISX0201_GL_TABLE = [
        "\u{3000}" => "\u{0020}",  // Ideographic space to space
        "\u{ff01}" => "\u{0021}",  // ！ to !
        "\u{ff02}" => "\u{0022}",  // ＂ to "
        "\u{ff03}" => "\u{0023}",  // ＃ to #
        "\u{ff04}" => "\u{0024}",  // ＄ to $
        "\u{ff05}" => "\u{0025}",  // ％ to %
        "\u{ff06}" => "\u{0026}",  // ＆ to &
        "\u{ff07}" => "\u{0027}",  // ＇ to '
        "\u{ff08}" => "\u{0028}",  // （ to (
        "\u{ff09}" => "\u{0029}",  // ） to )
        "\u{ff0a}" => "\u{002a}",  // ＊ to *
        "\u{ff0b}" => "\u{002b}",  // ＋ to +
        "\u{ff0c}" => "\u{002c}",  // ， to ,
        "\u{ff0d}" => "\u{002d}",  // － to -
        "\u{ff0e}" => "\u{002e}",  // ． to .
        "\u{ff0f}" => "\u{002f}",  // ／ to /
        "\u{ff10}" => "\u{0030}",  // ０ to 0
        "\u{ff11}" => "\u{0031}",  // １ to 1
        "\u{ff12}" => "\u{0032}",  // ２ to 2
        "\u{ff13}" => "\u{0033}",  // ３ to 3
        "\u{ff14}" => "\u{0034}",  // ４ to 4
        "\u{ff15}" => "\u{0035}",  // ５ to 5
        "\u{ff16}" => "\u{0036}",  // ６ to 6
        "\u{ff17}" => "\u{0037}",  // ７ to 7
        "\u{ff18}" => "\u{0038}",  // ８ to 8
        "\u{ff19}" => "\u{0039}",  // ９ to 9
        "\u{ff1a}" => "\u{003a}",  // ： to :
        "\u{ff1b}" => "\u{003b}",  // ； to ;
        "\u{ff1c}" => "\u{003c}",  // ＜ to <
        "\u{ff1d}" => "\u{003d}",  // ＝ to =
        "\u{ff1e}" => "\u{003e}",  // ＞ to >
        "\u{ff1f}" => "\u{003f}",  // ？ to ?
        "\u{ff20}" => "\u{0040}",  // ＠ to @
        "\u{ff21}" => "\u{0041}",  // Ａ to A
        "\u{ff22}" => "\u{0042}",  // Ｂ to B
        "\u{ff23}" => "\u{0043}",  // Ｃ to C
        "\u{ff24}" => "\u{0044}",  // Ｄ to D
        "\u{ff25}" => "\u{0045}",  // Ｅ to E
        "\u{ff26}" => "\u{0046}",  // Ｆ to F
        "\u{ff27}" => "\u{0047}",  // Ｇ to G
        "\u{ff28}" => "\u{0048}",  // Ｈ to H
        "\u{ff29}" => "\u{0049}",  // Ｉ to I
        "\u{ff2a}" => "\u{004a}",  // Ｊ to J
        "\u{ff2b}" => "\u{004b}",  // Ｋ to K
        "\u{ff2c}" => "\u{004c}",  // Ｌ to L
        "\u{ff2d}" => "\u{004d}",  // Ｍ to M
        "\u{ff2e}" => "\u{004e}",  // Ｎ to N
        "\u{ff2f}" => "\u{004f}",  // Ｏ to O
        "\u{ff30}" => "\u{0050}",  // Ｐ to P
        "\u{ff31}" => "\u{0051}",  // Ｑ to Q
        "\u{ff32}" => "\u{0052}",  // Ｒ to R
        "\u{ff33}" => "\u{0053}",  // Ｓ to S
        "\u{ff34}" => "\u{0054}",  // Ｔ to T
        "\u{ff35}" => "\u{0055}",  // Ｕ to U
        "\u{ff36}" => "\u{0056}",  // Ｖ to V
        "\u{ff37}" => "\u{0057}",  // Ｗ to W
        "\u{ff38}" => "\u{0058}",  // Ｘ to X
        "\u{ff39}" => "\u{0059}",  // Ｙ to Y
        "\u{ff3a}" => "\u{005a}",  // Ｚ to Z
        "\u{ff3b}" => "\u{005b}",  // ［ to [
        "\u{ff3d}" => "\u{005d}",  // ］ to ]
        "\u{ff3e}" => "\u{005e}",  // ＾ to ^
        "\u{ff3f}" => "\u{005f}",  // ＿ to _
        "\u{ff40}" => "\u{0060}",  // ｀ to `
        "\u{ff41}" => "\u{0061}",  // ａ to a
        "\u{ff42}" => "\u{0062}",  // ｂ to b
        "\u{ff43}" => "\u{0063}",  // ｃ to c
        "\u{ff44}" => "\u{0064}",  // ｄ to d
        "\u{ff45}" => "\u{0065}",  // ｅ to e
        "\u{ff46}" => "\u{0066}",  // ｆ to f
        "\u{ff47}" => "\u{0067}",  // ｇ to g
        "\u{ff48}" => "\u{0068}",  // ｈ to h
        "\u{ff49}" => "\u{0069}",  // ｉ to i
        "\u{ff4a}" => "\u{006a}",  // ｊ to j
        "\u{ff4b}" => "\u{006b}",  // ｋ to k
        "\u{ff4c}" => "\u{006c}",  // ｌ to l
        "\u{ff4d}" => "\u{006d}",  // ｍ to m
        "\u{ff4e}" => "\u{006e}",  // ｎ to n
        "\u{ff4f}" => "\u{006f}",  // ｏ to o
        "\u{ff50}" => "\u{0070}",  // ｐ to p
        "\u{ff51}" => "\u{0071}",  // ｑ to q
        "\u{ff52}" => "\u{0072}",  // ｒ to r
        "\u{ff53}" => "\u{0073}",  // ｓ to s
        "\u{ff54}" => "\u{0074}",  // ｔ to t
        "\u{ff55}" => "\u{0075}",  // ｕ to u
        "\u{ff56}" => "\u{0076}",  // ｖ to v
        "\u{ff57}" => "\u{0077}",  // ｗ to w
        "\u{ff58}" => "\u{0078}",  // ｘ to x
        "\u{ff59}" => "\u{0079}",  // ｙ to y
        "\u{ff5a}" => "\u{007a}",  // ｚ to z
        "\u{ff5b}" => "\u{007b}",  // ｛ to {
        "\u{ff5c}" => "\u{007c}",  // ｜ to |
        "\u{ff5d}" => "\u{007d}",  // ｝ to }
    ];

    /** @var array<string,array<string,string>> Special GL overrides */
    private const JISX0201_GL_OVERRIDES = [
        'u005cAsYenSign' => ["\u{ffe5}" => "\u{005c}"],  // ￥ to \
        'u005cAsBackslash' => ["\u{ff3c}" => "\u{005c}"],  // ＼ to \
        'u007eAsFullwidthTilde' => ["\u{ff5e}" => "\u{007e}"],  // ～ to ~
        'u007eAsWaveDash' => ["\u{301c}" => "\u{007e}"],  // 〜 to ~
        'u007eAsOverline' => ["\u{203e}" => "\u{007e}"],  // ‾ to ~
        'u007eAsFullwidthMacron' => ["\u{ffe3}" => "\u{007e}"],  // ￣ to ~
        'u00a5AsYenSign' => ["\u{ffe5}" => "\u{00a5}"],  // ￥ to ¥
    ];

    /** @var array<string,string> GR area mapping table (fullwidth katakana to halfwidth katakana) - generated from shared table */
    private static array $jisx0201GRTable;

    /** @var array<string,string> Voiced letters (dakuten/handakuten combinations) - generated from shared table */
    private static array $voicedLettersTable;

    /** @var array<string,string> Hiragana mappings (for convertHiraganas option) - generated from shared table */
    private static array $hiraganaMappings;

    /** @var array<string,string> Special punctuations */
    private const SPECIAL_PUNCTUATIONS_TABLE = [
        "\u{30a0}" => "\u{003d}",  // ゠ to =
    ];

    private bool $fullwidthToHalfwidth;
    private bool $convertGL;
    private bool $convertGR;
    private bool $convertUnsafeSpecials;
    private bool $convertHiraganas;
    private bool $combineVoicedSoundMarks;

    /**
     * @var array{u005cAsYenSign:bool,u005cAsBackslash:bool,u007eAsFullwidthTilde:bool,u007eAsWaveDash:bool,u007eAsOverline:bool,u007eAsFullwidthMacron:bool,u00a5AsYenSign:bool}
     */
    private array $overrides;

    /**
     * @var array<string, string>
     */
    private array $fwdMappings;

    /**
     * @var array<string, string>
     */
    private array $revMappings;

    /**
     * @var array<string, array<string, string>>
     */
    private array $voicedRevMappings;

    /**
     * Cache for forward mappings indexed by configuration key
     * @var array<string, array<string, string>>
     */
    private static array $fwdMappingsCache = [];

    /**
     * Cache for reverse mappings indexed by configuration key
     * @var array<string, array<string, string>>
     */
    private static array $revMappingsCache = [];

    /**
     * Cache for voiced reverse mappings indexed by configuration key
     * @var array<string, array<string, array<string, string>>>
     */
    private static array $voicedRevMappingsCache = [];

    /**
     * Static initialization
     */
    private static function initializeStaticData(): void
    {
        if (!isset(self::$jisx0201GRTable)) {
            self::$jisx0201GRTable = HiraKataTable::generateGRTable();
            self::$voicedLettersTable = HiraKataTable::generateVoicedLettersTable();
            self::$hiraganaMappings = HiraKataTable::generateHiraganaTable();
        }
    }

    /**
    * @param array{fullwidthToHalfwidth?:bool,convertGL?:bool,convertGR?:bool,convertUnsafeSpecials?:bool,convertHiraganas?:bool,combineVoicedSoundMarks?:bool,u005cAsYenSign?:bool,u005cAsBackslash?:bool,u007eAsFullwidthTilde?:bool,u007eAsWaveDash?:bool,u007eAsOverline?:bool,u007eAsFullwidthMacron?:bool,u00a5AsYenSign?:bool} $options
     */
    public function __construct(array $options = [])
    {
        $fullwidthToHalfwidth = $options['fullwidthToHalfwidth'] ?? true;
        $this->fullwidthToHalfwidth = $fullwidthToHalfwidth;
        $this->convertGL = $options['convertGL'] ?? true;
        $this->convertGR = $options['convertGR'] ?? true;
        if ($fullwidthToHalfwidth) {
            $this->convertUnsafeSpecials = $options['convertUnsafeSpecials'] ?? true;
            $this->convertHiraganas = $options['convertHiraganas'] ?? false;
            $this->combineVoicedSoundMarks = false; // unused in the forward mappings
            $this->overrides = [
                'u005cAsYenSign' => $options['u005cAsYenSign'] ?? !isset($options['u00a5AsYenSign']),
                'u005cAsBackslash' => $options['u005cAsBackslash'] ?? false,
                'u007eAsFullwidthTilde' => $options['u007eAsFullwidthTilde'] ?? true,
                'u007eAsWaveDash' => $options['u007eAsWaveDash'] ?? true,
                'u007eAsOverline' => $options['u007eAsOverline'] ?? false,
                'u007eAsFullwidthMacron' => $options['u007eAsFullwidthMacron'] ?? false,
                'u00a5AsYenSign' => $options['u00a5AsYenSign'] ?? false,
            ];
        } else {
            $this->convertUnsafeSpecials = $options['convertUnsafeSpecials'] ?? false;
            $this->convertHiraganas = false; // unused in the reverse mappings
            $this->combineVoicedSoundMarks = $options['combineVoicedSoundMarks'] ?? true;
            $this->overrides = [
                'u005cAsYenSign' => $options['u005cAsYenSign'] ?? !isset($options['u005cAsBackslash']),
                'u005cAsBackslash' => $options['u005cAsBackslash'] ?? false,
                'u007eAsFullwidthTilde' => $options['u007eAsFullwidthTilde'] ?? (
                    !isset($options['u007eAsWaveDash']) &&
                    !isset($options['u007eAsOverline']) &&
                    !isset($options['u007eAsFullwidthMacron'])
                ),
                'u007eAsWaveDash' => $options['u007eAsWaveDash'] ?? false,
                'u007eAsOverline' => $options['u007eAsOverline'] ?? false,
                'u007eAsFullwidthMacron' => $options['u007eAsFullwidthMacron'] ?? false,
                'u00a5AsYenSign' => $options['u00a5AsYenSign'] ?? false,
            ];
        }
        // Build mappings using cache
        $cacheKey = $this->generateCacheKey();
        $this->fwdMappings = $this->getFwdMappings($cacheKey);
        $this->revMappings = $this->getRevMappings($cacheKey);
        $this->voicedRevMappings = $this->getVoicedRevMappings($cacheKey);
    }

    /**
     * Generate a cache key based on current configuration
     */
    private function generateCacheKey(): string
    {
        return sprintf(
            '%d-%d-%d-%d-%d-%d-%d-%d-%d-%d-%d-%d',
            (int) $this->convertGL,
            (int) $this->convertGR,
            (int) $this->convertUnsafeSpecials,
            (int) $this->convertHiraganas,
            (int) $this->combineVoicedSoundMarks,
            (int) ($this->overrides['u005cAsYenSign'] ?? false),
            (int) ($this->overrides['u005cAsBackslash'] ?? false),
            (int) ($this->overrides['u007eAsFullwidthTilde'] ?? false),
            (int) ($this->overrides['u007eAsWaveDash'] ?? false),
            (int) ($this->overrides['u007eAsOverline'] ?? false),
            (int) ($this->overrides['u007eAsFullwidthMacron'] ?? false),
            (int) ($this->overrides['u00a5AsYenSign'] ?? false),
        );
    }

    /**
     * Get forward mappings with caching
     * @return array<string,string>
     */
    private function getFwdMappings(string $cacheKey): array
    {
        if (!isset(self::$fwdMappingsCache[$cacheKey])) {
            self::$fwdMappingsCache[$cacheKey] = $this->buildFwdMappings();
        }
        return self::$fwdMappingsCache[$cacheKey];
    }

    /**
     * Get reverse mappings with caching
     * @return array<string,string>
     */
    private function getRevMappings(string $cacheKey): array
    {
        if (!isset(self::$revMappingsCache[$cacheKey])) {
            self::$revMappingsCache[$cacheKey] = $this->buildRevMappings();
        }
        return self::$revMappingsCache[$cacheKey];
    }

    /**
     * Get voiced reverse mappings with caching
     * @return array<string, array<string, string>>
     */
    private function getVoicedRevMappings(string $cacheKey): array
    {
        if (!isset(self::$voicedRevMappingsCache[$cacheKey])) {
            self::$voicedRevMappingsCache[$cacheKey] = $this->buildVoicedRevMappings();
        }
        return self::$voicedRevMappingsCache[$cacheKey];
    }

    /**
     * @return array<string,string>
     */
    private function buildFwdMappings(): array
    {
        self::initializeStaticData();
        $mappings = [];

        if ($this->convertGL) {
            // Add basic GL mappings
            $mappings = array_merge($mappings, self::JISX0201_GL_TABLE);

            // Add override mappings
            foreach ($this->overrides as $key => $enabled) {
                if ($enabled) {
                    $mappings = array_merge($mappings, self::JISX0201_GL_OVERRIDES[$key]);
                }
            }

            if ($this->convertUnsafeSpecials) {
                $mappings = array_merge($mappings, self::SPECIAL_PUNCTUATIONS_TABLE);
            }
        }

        if ($this->convertGR) {
            // Add basic GR mappings
            $mappings = array_merge($mappings, self::$jisx0201GRTable);
            $mappings = array_merge($mappings, self::$voicedLettersTable);
            // Add combining marks
            $mappings["\u{3099}"] = "\u{ff9e}";  // combining dakuten
            $mappings["\u{309a}"] = "\u{ff9f}";  // combining handakuten

            if ($this->convertHiraganas) {
                $mappings = array_merge($mappings, self::$hiraganaMappings);
            }
        }

        return $mappings;
    }

    /**
     * @return array<string,string>
     */
    private function buildRevMappings(): array
    {
        self::initializeStaticData();
        /** @var array<string,string> */
        $mappings = [];

        if ($this->convertGL) {
            // Add basic GL reverse mappings
            /** @var array<string,string> This annotation is required to work around a PHPStan bug */
            $mappings = array_merge($mappings, array_flip(self::JISX0201_GL_TABLE));

            // Add override reverse mappings
            foreach ($this->overrides as $key => $enabled) {
                if ($enabled) {
                    $mappings = array_merge($mappings, array_flip(self::JISX0201_GL_OVERRIDES[$key]));
                }
            }

            if ($this->convertUnsafeSpecials) {
                $mappings = array_merge($mappings, array_flip(self::SPECIAL_PUNCTUATIONS_TABLE));
            }
        }

        if ($this->convertGR) {
            // Add basic GR reverse mappings
            $mappings = array_merge($mappings, array_flip(self::$jisx0201GRTable));
        }

        return $mappings;
    }

    /**
     * @return array<string, array<string, string>>
     */
    private function buildVoicedRevMappings(): array
    {
        self::initializeStaticData();
        $mappings = [];

        if ($this->combineVoicedSoundMarks && $this->convertGR) {
            foreach (self::$voicedLettersTable as $fw => $hw) {
                if (mb_strlen($hw, 'UTF-8') === 2) {
                    $baseChar = mb_substr($hw, 0, 1, 'UTF-8');
                    $voiceMark = mb_substr($hw, 1, 1, 'UTF-8');
                    if (!isset($mappings[$baseChar])) {
                        $mappings[$baseChar] = [];
                    }
                    $mappings[$baseChar][$voiceMark] = $fw;
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
        if ($this->fullwidthToHalfwidth) {
            return $this->convertFullwidthToHalfwidth($inputChars);
        } else {
            return $this->convertHalfwidthToFullwidth($inputChars);
        }
    }

    /**
     * @param iterable<Char> $chars
     * @return iterable<Char>
     */
    private function convertFullwidthToHalfwidth(iterable $chars): iterable
    {
        $offset = 0;
        foreach ($chars as $char) {
            $mapped = $this->fwdMappings[$char->c] ?? null;
            if ($mapped !== null) {
                yield new Char($mapped, $offset, $char);
                $offset += strlen($mapped);
            } else {
                yield $char->withOffset($offset);
                $offset += strlen($char->c);
            }
        }
    }

    /**
     * @param iterable<Char> $chars
     * @return iterable<Char>
     */
    private function convertHalfwidthToFullwidth(iterable $chars): iterable
    {
        $pendingChar = null;

        foreach ($chars as $char) {
            if ($pendingChar !== null) {
                // Check if this char can combine with the pending one
                [$baseChar, $voiceMappings] = $pendingChar;
                $combined = $voiceMappings[$char->c] ?? null;
                if ($combined !== null) {
                    // Yield the combined character
                    yield new Char($combined, $baseChar->offset, $baseChar);
                    $pendingChar = null;
                    continue;
                } else {
                    // Can't combine, yield the pending character first
                    $mapped = $this->revMappings[$baseChar->c] ?? null;
                    if ($mapped !== null) {
                        yield new Char($mapped, $baseChar->offset, $baseChar);
                    } else {
                        yield $baseChar;
                    }
                    $pendingChar = null;
                }
            }

            // Check if this character might start a combination
            if (isset($this->voicedRevMappings[$char->c])) {
                $pendingChar = [$char, $this->voicedRevMappings[$char->c]];
            } else {
                // Normal mapping
                $mapped = $this->revMappings[$char->c] ?? null;
                if ($mapped !== null) {
                    yield new Char($mapped, $char->offset, $char);
                } else {
                    yield $char;
                }
            }
        }

        // Handle any remaining pending character
        if ($pendingChar !== null) {
            [$baseChar, $_] = $pendingChar;
            $mapped = $this->revMappings[$baseChar->c] ?? null;
            if ($mapped !== null) {
                yield new Char($mapped, $baseChar->offset, $baseChar);
            } else {
                yield $baseChar;
            }
        }
    }
}
