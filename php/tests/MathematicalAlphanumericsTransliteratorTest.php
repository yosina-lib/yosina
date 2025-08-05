<?php

declare(strict_types=1);

use PHPUnit\Framework\Attributes\DataProvider;
use PHPUnit\Framework\TestCase;

use Yosina\Chars;
use Yosina\TransliteratorInterface;
use Yosina\TransliteratorRegistry;
use Yosina\Transliterators\MathematicalAlphanumericsTransliterator;

/**
 * Tests for MathematicalAlphanumericsTransliterator based on Java test cases.
 */
class MathematicalAlphanumericsTransliteratorTest extends TestCase
{
    /**
     * Test cases for mathematical alphanumerics transliterations.
     * @return array<array{string, string, string}>
     */
    public static function mathematicalAlphanumericsProvider(): array
    {
        return [
            // Mathematical Bold characters
            ["A", "𝐀", "Mathematical Bold A to regular A"],
            ["B", "𝐁", "Mathematical Bold B to regular B"],
            ["Z", "𝐙", "Mathematical Bold Z to regular Z"],
            ["a", "𝐚", "Mathematical Bold a to regular a"],
            ["b", "𝐛", "Mathematical Bold b to regular b"],
            ["z", "𝐳", "Mathematical Bold z to regular z"],

            // Mathematical Italic characters
            ["A", "𝐴", "Mathematical Italic A to regular A"],
            ["B", "𝐵", "Mathematical Italic B to regular B"],
            ["a", "𝑎", "Mathematical Italic a to regular a"],
            ["b", "𝑏", "Mathematical Italic b to regular b"],

            // Mathematical Bold Italic characters
            ["A", "𝑨", "Mathematical Bold Italic A to regular A"],
            ["a", "𝒂", "Mathematical Bold Italic a to regular a"],

            // Mathematical Script characters
            ["A", "𝒜", "Mathematical Script A to regular A"],
            ["a", "𝒶", "Mathematical Script a to regular a"],

            // Mathematical Bold Script characters
            ["A", "𝓐", "Mathematical Bold Script A to regular A"],
            ["a", "𝓪", "Mathematical Bold Script a to regular a"],

            // Mathematical Fraktur characters
            ["A", "𝔄", "Mathematical Fraktur A to regular A"],
            ["a", "𝔞", "Mathematical Fraktur a to regular a"],

            // Mathematical Double-struck characters
            ["A", "𝔸", "Mathematical Double-struck A to regular A"],
            ["a", "𝕒", "Mathematical Double-struck a to regular a"],

            // Mathematical Bold Fraktur characters
            ["A", "𝕬", "Mathematical Bold Fraktur A to regular A"],
            ["a", "𝖆", "Mathematical Bold Fraktur a to regular a"],

            // Mathematical Sans-serif characters
            ["A", "𝖠", "Mathematical Sans-serif A to regular A"],
            ["a", "𝖺", "Mathematical Sans-serif a to regular a"],

            // Mathematical Sans-serif Bold characters
            ["A", "𝗔", "Mathematical Sans-serif Bold A to regular A"],
            ["a", "𝗮", "Mathematical Sans-serif Bold a to regular a"],

            // Mathematical Sans-serif Italic characters
            ["A", "𝘈", "Mathematical Sans-serif Italic A to regular A"],
            ["a", "𝘢", "Mathematical Sans-serif Italic a to regular a"],

            // Mathematical Sans-serif Bold Italic characters
            ["A", "𝘼", "Mathematical Sans-serif Bold Italic A to regular A"],
            ["a", "𝙖", "Mathematical Sans-serif Bold Italic a to regular a"],

            // Mathematical Monospace characters
            ["A", "𝙰", "Mathematical Monospace A to regular A"],
            ["a", "𝚊", "Mathematical Monospace a to regular a"],

            // Mathematical digits
            ["0", "𝟎", "Mathematical Bold digit 0 to regular 0"],
            ["1", "𝟏", "Mathematical Bold digit 1 to regular 1"],
            ["9", "𝟗", "Mathematical Bold digit 9 to regular 9"],
        ];
    }

    #[DataProvider('mathematicalAlphanumericsProvider')]
    public function testMathematicalAlphanumericsTransliterations(string $expected, string $input, string $description): void
    {
        $transliterator = new MathematicalAlphanumericsTransliterator();

        $result = $this->processString($transliterator, $input);

        $this->assertEquals($expected, $result, $description);
    }

    public function testEmptyString(): void
    {
        $transliterator = new MathematicalAlphanumericsTransliterator();

        $result = $this->processString($transliterator, "");

        $this->assertEquals("", $result);
    }

    public function testUnmappedCharacters(): void
    {
        $transliterator = new MathematicalAlphanumericsTransliterator();

        $input = "hello world 123 !@# こんにちは";
        $result = $this->processString($transliterator, $input);

        $this->assertEquals($input, $result, "Unmapped characters should remain unchanged");
    }

    public function testMixedMathematicalContent(): void
    {
        $transliterator = new MathematicalAlphanumericsTransliterator();

        $input = "𝐀𝐁𝐂 regular ABC 𝟏𝟐𝟑";
        $expected = "ABC regular ABC 123";
        $result = $this->processString($transliterator, $input);

        $this->assertEquals($expected, $result, "Should convert mathematical characters to regular ASCII");
    }

    public function testMathematicalAlphabet(): void
    {
        $transliterator = new MathematicalAlphanumericsTransliterator();

        $input = "𝐀𝐁𝐂𝐃𝐄𝐅𝐆𝐇𝐈𝐉𝐊𝐋𝐌𝐍𝐎𝐏𝐐𝐑𝐒𝐓𝐔𝐕𝐖𝐗𝐘𝐙";
        $expected = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
        $result = $this->processString($transliterator, $input);

        $this->assertEquals($expected, $result, "Should convert full mathematical alphabet");
    }

    public function testMathematicalLowercaseAlphabet(): void
    {
        $transliterator = new MathematicalAlphanumericsTransliterator();

        $input = "𝐚𝐛𝐜𝐝𝐞𝐟𝐠𝐡𝐢𝐣𝐤𝐥𝐦𝐧𝐨𝐩𝐪𝐫𝐬𝐭𝐮𝐯𝐰𝐱𝐲𝐳";
        $expected = "abcdefghijklmnopqrstuvwxyz";
        $result = $this->processString($transliterator, $input);

        $this->assertEquals($expected, $result, "Should convert full mathematical lowercase alphabet");
    }

    public function testMathematicalDigits(): void
    {
        $transliterator = new MathematicalAlphanumericsTransliterator();

        $input = "𝟎𝟏𝟐𝟑𝟒𝟓𝟔𝟕𝟖𝟗";
        $expected = "0123456789";
        $result = $this->processString($transliterator, $input);

        $this->assertEquals($expected, $result, "Should convert mathematical digits to regular digits");
    }

    public function testDifferentMathematicalStyles(): void
    {
        $transliterator = new MathematicalAlphanumericsTransliterator();

        $input = "𝐀𝐴𝑨𝒜𝓐𝔄𝔸𝕬𝖠𝗔𝘈𝘼𝙰"; // Different styles of A
        $expected = "AAAAAAAAAAAAA";
        $result = $this->processString($transliterator, $input);

        $this->assertEquals($expected, $result, "Should convert all mathematical styles to regular A");
    }

    public function testMathematicalEquation(): void
    {
        $transliterator = new MathematicalAlphanumericsTransliterator();

        $input = "𝒇(𝒙) = 𝒎𝒙 + 𝒃";
        $expected = "f(x) = mx + b";
        $result = $this->processString($transliterator, $input);

        $this->assertEquals($expected, $result, "Should convert mathematical equation to regular text");
    }

    public function testSpecialMathematicalCharacters(): void
    {
        $transliterator = new MathematicalAlphanumericsTransliterator();

        $input = "𝔄𝔞 𝕬𝖆 𝖠𝖺"; // Fraktur, Bold Fraktur, Sans-serif
        $expected = "Aa Aa Aa";
        $result = $this->processString($transliterator, $input);

        $this->assertEquals($expected, $result, "Should convert special mathematical styles to regular characters");
    }

    public function testRegistryIntegration(): void
    {
        // Test that the transliterator can be created via registry
        $factory = TransliteratorRegistry::getTransliteratorFactory('mathematical-alphanumerics');
        $transliterator = $factory([]);

        $input = "𝐀";
        $expected = "A";
        $result = $this->processString($transliterator, $input);

        $this->assertEquals($expected, $result, "Registry integration failed");
    }

    public function testIteratorProperties(): void
    {
        $transliterator = new MathematicalAlphanumericsTransliterator();

        $input = "𝐀𝐁𝐂";
        $chars = Chars::buildCharArray($input);
        $result = $transliterator($chars);
        $this->assertEquals(['A', 'B', 'C', ''], array_map(static fn ($c) => $c->c, iterator_to_array($result)));
    }

    private function processString(TransliteratorInterface $transliterator, string $input): string
    {
        $chars = Chars::buildCharArray($input);
        return Chars::fromChars($transliterator($chars));
    }
}