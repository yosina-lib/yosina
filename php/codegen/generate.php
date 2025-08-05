<?php

declare(strict_types=1);

/**
 * Code generator for Yosina PHP transliterators.
 */
class YosinaCodeGenerator
{
    private string $dataRoot;
    private string $destRoot;

    public function __construct()
    {
        $this->dataRoot = __DIR__ . '/../../data';
        $this->destRoot = __DIR__ . '/../src/Transliterators';
    }

    public function generate(): void
    {
        echo "Loading datasets from: {$this->dataRoot}\n";
        echo "Writing output to: {$this->destRoot}\n";

        $this->generateSimpleTransliterators();
        echo "Code generation complete!\n";
    }

    private function generateSimpleTransliterators(): void
    {
        $transliterators = [
            ['spaces', 'Spaces', 'Replace various space characters with plain whitespace.', 'spaces.json'],
            ['radicals', 'Radicals', 'Replace Kangxi radicals with equivalent CJK ideographs.', 'radicals.json'],
            ['mathematical-alphanumerics', 'MathematicalAlphanumerics', 'Replace mathematical alphanumeric symbols with plain characters.', 'mathematical-alphanumerics.json'],
            ['ideographic-annotations', 'IdeographicAnnotations', 'Replace ideographic annotation marks used in traditional translation.', 'ideographic-annotation-marks.json'],
            ['kanji-old-new', 'KanjiOldNew', 'Replace old-style kanji with modern equivalents.', 'kanji-old-new-form.json'],
        ];

        foreach ($transliterators as [$identifier, $className, $description, $dataFile]) {
            $this->generateSimpleTransliterator($identifier, $className, $description, $dataFile);
        }

        // Generate complex transliterators
        $this->generateHyphensTransliterator();
        $this->generateIvsSvsBaseTransliterator();
        $this->generateCombinedTransliterator();
        $this->generateCircledOrSquaredTransliterator();
    }

    private function generateSimpleTransliterator(string $identifier, string $className, string $description, string $dataFile): void
    {
        $dataPath = "{$this->dataRoot}/{$dataFile}";
        if (!file_exists($dataPath)) {
            echo "Warning: Data file not found: {$dataPath}\n";
            return;
        }

        $data = json_decode(file_get_contents($dataPath), true);
        if (!$data) {
            echo "Warning: Failed to parse JSON data: {$dataPath}\n";
            return;
        }

        // Special handling for kanji-old-new data structure
        if ($identifier === 'kanji-old-new') {
            $mappings = $this->convertKanjiOldNewData($data);
        } else {
            $mappings = $this->convertDataToMappings($data);
        }

        $output = $this->renderSimpleTransliterator($className, $description, $mappings);

        $filename = "{$className}Transliterator.php";
        $filepath = "{$this->destRoot}/{$filename}";

        if (!is_dir($this->destRoot)) {
            mkdir($this->destRoot, 0755, true);
        }

        file_put_contents($filepath, $output);
        echo "Generated: {$filename}\n";
    }

    private static function convertDataToMappings(array $data): array
    {
        $mappings = [];
        foreach ($data as $from => $to) {
            $fromStr = is_string($from) ? $from : "U+{$from}";
            if ($to === null) {
                $mappings[self::convertUnicodeNotation($fromStr)] = '';
            } else {
                $toStr = is_string($to) ? $to : "U+{$to}";
                $mappings[self::convertUnicodeNotation($fromStr)] = self::convertUnicodeNotation($toStr);
            }
        }
        return $mappings;
    }

    private static function convertKanjiOldNewData(array $data): array
    {
        $mappings = [];

        // Data structure: array of [oldRecord, newRecord] tuples
        foreach ($data as $tuple) {
            if (!is_array($tuple) || count($tuple) !== 2) {
                continue;
            }

            [$oldRecord, $newRecord] = $tuple;

            // Convert old kanji IVS sequence to string
            $oldChar = self::convertIvsRecord($oldRecord);
            // Convert new kanji IVS sequence to string
            $newChar = self::convertIvsRecord($newRecord);

            if ($oldChar && $newChar) {
                $mappings[$oldChar] = $newChar;
            }
        }

        return $mappings;
    }

    private static function convertIvsRecord(array $record): ?string
    {
        if (!isset($record['ivs']) || !is_array($record['ivs'])) {
            return null;
        }

        $result = '';
        foreach ($record['ivs'] as $codepoint) {
            if (is_string($codepoint)) {
                $result .= self::convertUnicodeNotation($codepoint);
            }
        }

        return $result ?: null;
    }

    private static function unicodeToCodepoint(string $unicode): int
    {
        if (preg_match('/^U\+([0-9A-Fa-f]+)$/', $unicode, $matches)) {
            return hexdec($matches[1]);
        }
        throw new InvalidArgumentException();
    }

    private static function convertUnicodeNotation(string $unicode): string
    {
        // Convert "U+1234" to actual Unicode character
        return mb_chr(self::unicodeToCodepoint($unicode), 'UTF-8');
    }

    private static function escapeUnicodeString(string $str): string
    {
        // Convert a Unicode string to escaped representation for PHP code generation
        $result = '';
        $chars = mb_str_split($str, 1, 'UTF-8');

        foreach ($chars as $char) {
            $codepoint = mb_ord($char, 'UTF-8');
            if ($codepoint === false) {
                continue;
            }

            // Use Unicode escape notation for all non-ASCII characters
            if ($codepoint > 127) {
                $result .= sprintf('\u{%X}', $codepoint);
            } else {
                // For ASCII characters, escape special ones
                switch ($char) {
                    case '"':
                        $result .= '\\"';
                        break;
                    case '\\':
                        $result .= '\\\\';
                        break;
                    case "\n":
                        $result .= '\\n';
                        break;
                    case "\r":
                        $result .= '\\r';
                        break;
                    case "\t":
                        $result .= '\\t';
                        break;
                    default:
                        $result .= $char;
                        break;
                }
            }
        }

        return $result;
    }

    private static function phpStringLiteral(string $str): string
    {
        $escaped = self::escapeUnicodeString($str);
        if ($escaped === $str) {
            // Use double quotes with Unicode escapes for non-ASCII characters
            return '"' . $escaped . '"';
        } else {
            // Use var_export for ASCII-only strings
            return var_export($str, true);
        }
    }

    private function renderSimpleTransliterator(string $className, string $description, array $mappings): string
    {
        $mappingsCode = '';
        foreach ($mappings as $from => $to) {
            $fromCode = $this->phpStringLiteral($from);
            $toCode = $this->phpStringLiteral($to);
            $mappingsCode .= "        $fromCode => $toCode,\n";
        }
        $mappingsCode = rtrim($mappingsCode, ",\n");

        return <<<PHP
<?php

declare(strict_types=1);

namespace Yosina\\Transliterators;

use Yosina\\Char;
use Yosina\\TransliteratorInterface;

/**
 * {$description}
 */
class {$className}Transliterator implements TransliteratorInterface
{
    private const MAPPINGS = [
{$mappingsCode}
    ];

    /**
     * @param array<string, mixed> \$options
     */
    public function __construct(/* @phpstan-ignore constructor.unusedParameter */ array \$options = [])
    {
    }

    /**
     * @param iterable<Char> \$inputChars
     * @return iterable<Char>
     */
    public function __invoke(iterable \$inputChars): iterable
    {
        \$offset = 0;
        foreach (\$inputChars as \$char) {
            \$replacement = self::MAPPINGS[\$char->c] ?? null;
            if (\$replacement !== null) {
                yield new Char(\$replacement, \$offset, \$char);
                \$offset += strlen(\$replacement);
            } else {
                yield \$char->withOffset(\$offset);
                \$offset += strlen(\$char->c);
            }
        }
    }
}
PHP;
    }

    private function generateHyphensTransliterator(): void
    {
        $dataPath = "{$this->dataRoot}/hyphens.json";
        if (!file_exists($dataPath)) {
            echo "Warning: Hyphens data file not found: {$dataPath}\n";
            return;
        }

        $data = json_decode(file_get_contents($dataPath), true);
        if (!$data) {
            echo "Warning: Failed to parse hyphens JSON data: {$dataPath}\n";
            return;
        }

        $output = $this->renderHyphensTransliterator($data);

        $filename = "HyphensTransliterator.php";
        $filepath = "{$this->destRoot}/{$filename}";

        file_put_contents($filepath, $output);
        echo "Generated: {$filename}\n";
    }

    private function generateIvsSvsBaseTransliterator(): void
    {
        $dataPath = "{$this->dataRoot}/ivs-svs-base-mappings.json";
        if (!file_exists($dataPath)) {
            echo "Warning: IVS/SVS data file not found: {$dataPath}\n";
            return;
        }

        $data = json_decode(file_get_contents($dataPath), true);
        if (!$data) {
            echo "Warning: Failed to parse IVS/SVS JSON data: {$dataPath}\n";
            return;
        }

        // Generate binary data file
        $this->generateIvsSvsBinaryData($data);
    }

    private function generateIvsSvsBinaryData(array $data): void
    {
        $outputPath = "{$this->destRoot}/ivs_svs_base.data";

        // Ensure output directory exists
        $outputDir = dirname($outputPath);
        if (!is_dir($outputDir)) {
            mkdir($outputDir, 0755, true);
        }

        // Build binary data
        $binaryData = '';

        // Write record count
        $binaryData .= pack('N', count($data));

        foreach ($data as $record) {
            // IVS (2 ints)
            $ivsCodepoint1 = 0;
            $ivsCodepoint2 = 0;
            if (isset($record['ivs']) && is_array($record['ivs']) && count($record['ivs']) >= 1) {
                $ivsCodepoint1 = $this->unicodeToCodepoint($record['ivs'][0]);
                if (count($record['ivs']) >= 2) {
                    $ivsCodepoint2 = $this->unicodeToCodepoint($record['ivs'][1]);
                }
            }
            $binaryData .= pack('N', $ivsCodepoint1);
            $binaryData .= pack('N', $ivsCodepoint2);

            // SVS (2 ints)
            $svsCodepoint1 = 0;
            $svsCodepoint2 = 0;
            if (isset($record['svs']) && is_array($record['svs']) && count($record['svs']) >= 1) {
                $svsCodepoint1 = $this->unicodeToCodepoint($record['svs'][0]);
                if (count($record['svs']) >= 2) {
                    $svsCodepoint2 = $this->unicodeToCodepoint($record['svs'][1]);
                }
            }
            $binaryData .= pack('N', $svsCodepoint1);
            $binaryData .= pack('N', $svsCodepoint2);

            // Base90 (1 int)
            $base90Codepoint = isset($record['base90']) ? $this->unicodeToCodepoint($record['base90']) : 0;
            $binaryData .= pack('N', $base90Codepoint);

            // Base2004 (1 int)
            $base2004Codepoint = isset($record['base2004']) ? $this->unicodeToCodepoint($record['base2004']) : 0;
            $binaryData .= pack('N', $base2004Codepoint);
        }

        // Write binary data to file
        if (file_put_contents($outputPath, $binaryData) === false) {
            echo "Error: Failed to write binary data file: {$outputPath}\n";
            return;
        }

        echo "Generated binary data file: {$outputPath} (" . number_format(strlen($binaryData)) . " bytes)\n";
    }

    private function renderHyphensTransliterator(array $data): string
    {
        $recordsCode = '';
        foreach ($data as $record) {
            $codeChar = self::convertUnicodeNotation($record['code']);
            $code = self::escapeUnicodeString($codeChar);

            $ascii = 'null';
            if (!empty($record['ascii']) && is_array($record['ascii'])) {
                $asciiChar = self::convertUnicodeNotation($record['ascii'][0]);
                $ascii = '"' . self::escapeUnicodeString($asciiChar) . '"';
            }

            $jisx0201 = 'null';
            if (!empty($record['jisx0201']) && is_array($record['jisx0201'])) {
                $jisx0201Char = self::convertUnicodeNotation($record['jisx0201'][0]);
                $jisx0201 = '"' . self::escapeUnicodeString($jisx0201Char) . '"';
            }

            $jisx0208_90 = 'null';
            if (!empty($record['jisx0208-1978']) && is_array($record['jisx0208-1978'])) {
                $jisx0208_90Char = self::convertUnicodeNotation($record['jisx0208-1978'][0]);
                $jisx0208_90 = '"' . self::escapeUnicodeString($jisx0208_90Char) . '"';
            }

            $jisx0208_90_windows = 'null';
            if (!empty($record['jisx0208-1978-windows']) && is_array($record['jisx0208-1978-windows'])) {
                $jisx0208_90_windowsChar = self::convertUnicodeNotation($record['jisx0208-1978-windows'][0]);
                $jisx0208_90_windows = '"' . self::escapeUnicodeString($jisx0208_90_windowsChar) . '"';
            }

            $jisx0208_verbatim = 'null';
            if (!empty($record['jisx0208-verbatim']) && !is_null($record['jisx0208-verbatim'])) {
                $jisx0208_verbatimChar = self::convertUnicodeNotation($record['jisx0208-verbatim']);
                $jisx0208_verbatim = '"' . self::escapeUnicodeString($jisx0208_verbatimChar) . '"';
            }

            $recordsCode .= <<<PHP
        "$code" => [
            'ascii' => $ascii,
            'jisx0201' => $jisx0201,
            'jisx0208_90' => $jisx0208_90,
            'jisx0208_90_windows' => $jisx0208_90_windows,
            'jisx0208_verbatim' => $jisx0208_verbatim,
        ],

PHP;
        }

        return <<<PHP
<?php

declare(strict_types=1);

namespace Yosina\\Transliterators;

use Yosina\\Char;
use Yosina\\TransliteratorInterface;

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
{$recordsCode}    ];

    /**
     * @var array<int, string>
     */
    private array \$precedence;

    /**
     * @param array<string, mixed> \$options
     */
    public function __construct(array \$options = [])
    {
        \$precedence = \$options['precedence'] ?? self::DEFAULT_PRECEDENCE;
        \$this->precedence = is_array(\$precedence) ? \$precedence : self::DEFAULT_PRECEDENCE;
    }

    /**
     * @param iterable<Char> \$inputChars
     * @return iterable<Char>
     */
    public function __invoke(iterable \$inputChars): iterable
    {
        \$offset = 0;
        foreach (\$inputChars as \$char) {
            \$record = self::MAPPINGS[\$char->c] ?? null;
            if (\$record !== null) {
                \$replacement = \$this->getReplacement(\$record);
                if (\$replacement !== null && \$replacement !== \$char->c) {
                    yield new Char(\$replacement, \$offset, \$char);
                    \$offset += strlen(\$replacement);
                } else {
                    yield \$char->withOffset(\$offset);
                    \$offset += strlen(\$char->c);
                }
            } else {
                yield \$char;
            }
        }
    }
    
    /**
     * @param array<string, string|null> \$record
     */
    private function getReplacement(array \$record): ?string
    {
        foreach (\$this->precedence as \$mappingType) {
            \$replacement = \$record[\$mappingType] ?? null;
            if (\$replacement !== null) {
                return \$replacement;
            }
        }
        return null;
    }
}
PHP;
    }

    private function generateCombinedTransliterator(): void
    {
        $dataPath = "{$this->dataRoot}/combined-chars.json";
        if (!file_exists($dataPath)) {
            echo "Warning: Combined data file not found: {$dataPath}\n";
            return;
        }

        $data = json_decode(file_get_contents($dataPath), true);
        if (!$data) {
            echo "Warning: Failed to parse combined JSON data: {$dataPath}\n";
            return;
        }

        $mappings = [];
        foreach ($data as $from => $to) {
            $fromChar = self::convertUnicodeNotation($from);
            $toChars = mb_str_split($to, 1, 'UTF-8');
            $mappings[$fromChar] = $toChars;
        }

        $output = $this->renderCombinedTransliterator($mappings);

        $filename = "CombinedTransliterator.php";
        $filepath = "{$this->destRoot}/{$filename}";

        file_put_contents($filepath, $output);
        echo "Generated: {$filename}\n";
    }

    private function generateCircledOrSquaredTransliterator(): void
    {
        $dataPath = "{$this->dataRoot}/circled-or-squared.json";
        if (!file_exists($dataPath)) {
            echo "Warning: Circled-or-squared data file not found: {$dataPath}\n";
            return;
        }

        $data = json_decode(file_get_contents($dataPath), true);
        if (!$data) {
            echo "Warning: Failed to parse circled-or-squared JSON data: {$dataPath}\n";
            return;
        }

        $mappings = [];
        foreach ($data as $from => $record) {
            $fromChar = self::convertUnicodeNotation($from);
            $mappings[$fromChar] = $record;
        }

        $output = $this->renderCircledOrSquaredTransliterator($mappings);

        $filename = "CircledOrSquaredTransliterator.php";
        $filepath = "{$this->destRoot}/{$filename}";

        file_put_contents($filepath, $output);
        echo "Generated: {$filename}\n";
    }

    private function renderCombinedTransliterator(array $mappings): string
    {
        $mappingsCode = '';
        foreach ($mappings as $from => $toArray) {
            $fromCode = $this->phpStringLiteral($from);
            $toArrayCode = '[' . implode(', ', array_map([$this, 'phpStringLiteral'], $toArray)) . ']';
            $mappingsCode .= "        $fromCode => $toArrayCode,\n";
        }
        $mappingsCode = rtrim($mappingsCode, ",\n");

        return <<<PHP
<?php

declare(strict_types=1);

namespace Yosina\\Transliterators;

use Yosina\\Char;
use Yosina\\TransliteratorInterface;

/**
 * Replace single characters with arrays of characters.
 */
class CombinedTransliterator implements TransliteratorInterface
{
    private const MAPPINGS = [
{$mappingsCode}
    ];

    /**
     * @param array<string, mixed> \$options
     */
    public function __construct(/* @phpstan-ignore constructor.unusedParameter */ array \$options = [])
    {
    }

    /**
     * @param iterable<Char> \$inputChars
     * @return iterable<Char>
     */
    public function __invoke(iterable \$inputChars): iterable
    {
        \$offset = 0;
        foreach (\$inputChars as \$char) {
            \$replacement = self::MAPPINGS[\$char->c] ?? null;
            if (\$replacement !== null && is_array(\$replacement)) {
                foreach (\$replacement as \$replacementChar) {
                    yield new Char(\$replacementChar, \$offset, \$char);
                    \$offset += strlen(\$replacementChar);
                }
            } else {
                yield \$char->withOffset(\$offset);
                \$offset += strlen(\$char->c);
            }
        }
    }
}
PHP;
    }

    private function renderCircledOrSquaredTransliterator(array $mappings): string
    {
        $mappingsCode = '';
        foreach ($mappings as $from => $record) {
            $fromCode = $this->phpStringLiteral($from);
            $rendering = $this->phpStringLiteral($record['rendering']);
            $type = $this->phpStringLiteral($record['type']);
            $emoji = $record['emoji'] ? 'true' : 'false';
            $mappingsCode .= "        $fromCode => ['rendering' => $rendering, 'type' => $type, 'emoji' => $emoji],\n";
        }
        $mappingsCode = rtrim($mappingsCode, ",\n");

        return <<<PHP
<?php

declare(strict_types=1);

namespace Yosina\\Transliterators;

use Yosina\\Char;
use Yosina\\TransliteratorInterface;

/**
 * Replace circled or squared characters with templated forms.
 */
class CircledOrSquaredTransliterator implements TransliteratorInterface
{
    private const MAPPINGS = [
{$mappingsCode}
    ];

    /**
     * @var array<string, string>
     */
    private array \$templates;

    private bool \$includeEmojis;

    /**
     * @param array{templates?:array{circle?:string,square?:string},includeEmojis?:bool} \$options
     */
    public function __construct(array \$options = [])
    {
        \$this->templates = [
            'circle' => \$options['templates']['circle'] ?? '(?)',
            'square' => \$options['templates']['square'] ?? '[?]',
        ];
        \$this->includeEmojis = (bool) (\$options['includeEmojis'] ?? false);
    }

    /**
     * @param iterable<Char> \$inputChars
     * @return iterable<Char>
     */
    public function __invoke(iterable \$inputChars): iterable
    {
        \$offset = 0;
        foreach (\$inputChars as \$char) {
            \$record = self::MAPPINGS[\$char->c] ?? null;
            if (\$record !== null) {
                // Skip emoji characters if not included
                if (\$record['emoji'] && !\$this->includeEmojis) {
                    yield \$char;
                    continue;
                }

                // Get template
                \$template = \$this->templates[\$record['type']] ?? '?';
                \$replacement = str_replace('?', \$record['rendering'], \$template);

                if (\$replacement === '') {
                    yield \$char;
                    continue;
                }

                // Yield each character in the replacement string
                \$replacementChars = mb_str_split(\$replacement, 1, 'UTF-8');
                foreach (\$replacementChars as \$replacementChar) {
                    yield new Char(\$replacementChar, \$offset, \$char);
                    \$offset += strlen(\$replacementChar);
                }
            } else {
                yield \$char->withOffset(\$offset);
                \$offset += strlen(\$char->c);
            }
        }
    }
}
PHP;
    }
}

// Run the generator
$generator = new YosinaCodeGenerator();
$generator->generate();
