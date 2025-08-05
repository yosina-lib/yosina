<?php

declare(strict_types=1);

use PHPUnit\Framework\Attributes\DataProvider;
use PHPUnit\Framework\TestCase;

use Yosina\Chars;
use Yosina\TransliteratorInterface;
use Yosina\TransliteratorRegistry;
use Yosina\Transliterators\SpacesTransliterator;

/**
 * Tests for SpacesTransliterator based on Java test cases.
 */
class SpacesTransliteratorTest extends TestCase
{
    /**
     * Test cases for spaces transliterations.
     * @return array<array{string, string, string}>
     */
    public static function spacesProvider(): array
    {
        return [
            [" ", " ", "Regular space remains unchanged"],
            [" ", " ", "En quad to regular space"],
            [" ", " ", "Em quad to regular space"],
            [" ", "　", "Ideographic space to regular space"],
            [" ", "ﾠ", "Halfwidth ideographic space to regular space"],
            [" ", " ", "En space to regular space"],
            [" ", " ", "Em space to regular space"],
            [" ", " ", "Three-per-em space to regular space"],
            [" ", " ", "Four-per-em space to regular space"],
            [" ", "ㅤ", "Hangul filler to regular space"],
            [" ", " ", "Six-per-em space to regular space"],
            [" ", " ", "Figure space to regular space"],
            [" ", " ", "Punctuation space to regular space"],
            [" ", " ", "Thin space to regular space"],
            [" ", " ", "Hair space to regular space"],
            [" ", " ", "Narrow no-break space to regular space"],
            [" ", "​", "Zero width space to regular space"],
            [" ", " ", "Medium mathematical space to regular space"],
            [" ", " ", "Word joiner to regular space"],
        ];
    }

    #[DataProvider('spacesProvider')]
    public function testSpacesTransliterations(string $expected, string $input, string $description): void
    {
        $transliterator = new SpacesTransliterator();

        $result = $this->processString($transliterator, $input);

        $this->assertEquals($expected, $result, $description);
    }

    public function testEmptyString(): void
    {
        $transliterator = new SpacesTransliterator();

        $result = $this->processString($transliterator, "");

        $this->assertEquals("", $result);
    }

    public function testUnmappedCharacters(): void
    {
        $transliterator = new SpacesTransliterator();

        $input = "hello world abc123";
        $result = $this->processString($transliterator, $input);

        $this->assertEquals($input, $result, "Unmapped characters should remain unchanged");
    }

    public function testMixedSpacesContent(): void
    {
        $transliterator = new SpacesTransliterator();

        $input = "hello　world test　data";
        $expected = "hello world test data";
        $result = $this->processString($transliterator, $input);

        $this->assertEquals($expected, $result, "Should convert ideographic spaces to regular spaces");
    }

    public function testMultipleSpaceTypes(): void
    {
        $transliterator = new SpacesTransliterator();

        $input = "word　word word word";
        $expected = "word word word word";
        $result = $this->processString($transliterator, $input);

        $this->assertEquals($expected, $result, "Should normalize all space types to regular spaces");
    }

    public function testJapaneseTextWithIdeographicSpaces(): void
    {
        $transliterator = new SpacesTransliterator();

        $input = "こんにちは　世界　です";
        $expected = "こんにちは 世界 です";
        $result = $this->processString($transliterator, $input);

        $this->assertEquals($expected, $result, "Should convert Japanese ideographic spaces");
    }

    public function testHalfwidthIdeographicSpace(): void
    {
        $transliterator = new SpacesTransliterator();

        $input = "testﾠdata";
        $expected = "test data";
        $result = $this->processString($transliterator, $input);

        $this->assertEquals($expected, $result, "Should convert halfwidth ideographic space");
    }

    public function testZeroWidthAndInvisibleSpaces(): void
    {
        $transliterator = new SpacesTransliterator();

        $input = "word​word"; // Contains zero width space
        $expected = "word word";
        $result = $this->processString($transliterator, $input);

        $this->assertEquals($expected, $result, "Should convert zero width space to regular space");
    }

    public function testHangulFiller(): void
    {
        $transliterator = new SpacesTransliterator();

        $input = "testㅤdata";
        $expected = "test data";
        $result = $this->processString($transliterator, $input);

        $this->assertEquals($expected, $result, "Should convert Hangul filler to regular space");
    }

    public function testConsecutiveSpaces(): void
    {
        $transliterator = new SpacesTransliterator();

        $input = "word　　　word";
        $expected = "word   word";
        $result = $this->processString($transliterator, $input);

        $this->assertEquals($expected, $result, "Should convert consecutive ideographic spaces");
    }

    public function testVariousUnicodeSpaces(): void
    {
        $transliterator = new SpacesTransliterator();

        // Test various Unicode space characters
        $testCases = [
            [" ", "\u{0020}", "Regular space remains unchanged"],
            [" ", "\u{00A0}", "Non-breaking space to regular space"],
            [" ", "\u{2000}", "En quad to regular space"],
            [" ", "\u{2001}", "Em quad to regular space"],
            [" ", "\u{2002}", "En space to regular space"],
            [" ", "\u{2003}", "Em space to regular space"],
            [" ", "\u{2004}", "Three-per-em space to regular space"],
            [" ", "\u{2005}", "Four-per-em space to regular space"],
            [" ", "\u{2006}", "Six-per-em space to regular space"],
            [" ", "\u{2007}", "Figure space to regular space"],
            [" ", "\u{2008}", "Punctuation space to regular space"],
            [" ", "\u{2009}", "Thin space to regular space"],
            [" ", "\u{200A}", "Hair space to regular space"],
            [" ", "\u{202F}", "Narrow no-break space to regular space"],
            [" ", "\u{205F}", "Medium mathematical space to regular space"],
            [" ", "\u{3000}", "Ideographic space to regular space"],
        ];

        foreach ($testCases as [$expected, $input, $description]) {
            $result = $this->processString($transliterator, $input);
            $this->assertEquals($expected, $result, $description);
        }
    }

    public function testRegistryIntegration(): void
    {
        // Test that the transliterator can be created via registry
        $factory = TransliteratorRegistry::getTransliteratorFactory('spaces');
        $transliterator = $factory([]);

        $input = "　";
        $expected = " ";
        $result = $this->processString($transliterator, $input);

        $this->assertEquals($expected, $result, "Registry integration failed");
    }

    public function testIteratorProperties(): void
    {
        $transliterator = new SpacesTransliterator();

        $input = "test　data";
        $chars = Chars::buildCharArray($input);
        $result = $transliterator($chars);
        $this->assertEquals(['t', 'e', 's', 't', ' ', 'd', 'a', 't', 'a', ''], array_map(static fn ($c) => $c->c, iterator_to_array($result)));
    }

    private function processString(TransliteratorInterface $transliterator, string $input): string
    {
        $chars = Chars::buildCharArray($input);
        return Chars::fromChars($transliterator($chars));
    }
}