<?php

declare(strict_types=1);

use PHPUnit\Framework\Attributes\DataProvider;
use PHPUnit\Framework\TestCase;

use Yosina\Chars;
use Yosina\TransliteratorInterface;
use Yosina\TransliteratorRegistry;
use Yosina\Transliterators\IdeographicAnnotationsTransliterator;

/**
 * Tests for IdeographicAnnotationsTransliterator based on Java data mappings.
 */
class IdeographicAnnotationsTransliteratorTest extends TestCase
{
    /**
     * Test cases for ideographic annotations transliterations.
     * @return array<array{string, string, string}>
     */
    public static function ideographicAnnotationsProvider(): array
    {
        return [
            // Based on data from ideographic_annotations.data
            ["一", "㆒", "Ideographic annotation one to regular one"],
            ["二", "㆓", "Ideographic annotation two to regular two"],
            ["三", "㆔", "Ideographic annotation three to regular three"],
            ["四", "㆕", "Ideographic annotation four to regular four"],
            ["上", "㆖", "Ideographic annotation above to regular above"],
            ["中", "㆗", "Ideographic annotation middle to regular middle"],
            ["下", "㆘", "Ideographic annotation below to regular below"],
            ["甲", "㆙", "Ideographic annotation first to regular first"],
            ["乙", "㆚", "Ideographic annotation second to regular second"],
            ["丙", "㆛", "Ideographic annotation third to regular third"],
            ["丁", "㆜", "Ideographic annotation fourth to regular fourth"],
            ["天", "㆝", "Ideographic annotation heaven to regular heaven"],
            ["地", "㆞", "Ideographic annotation earth to regular earth"],
            ["人", "㆟", "Ideographic annotation person to regular person"],
        ];
    }

    #[DataProvider('ideographicAnnotationsProvider')]
    public function testIdeographicAnnotationsTransliterations(string $expected, string $input, string $description): void
    {
        $transliterator = new IdeographicAnnotationsTransliterator();

        $result = $this->processString($transliterator, $input);

        $this->assertEquals($expected, $result, $description);
    }

    public function testEmptyString(): void
    {
        $transliterator = new IdeographicAnnotationsTransliterator();

        $result = $this->processString($transliterator, "");

        $this->assertEquals("", $result);
    }

    public function testUnmappedCharacters(): void
    {
        $transliterator = new IdeographicAnnotationsTransliterator();

        $input = "hello world 123 abc こんにちは 漢字";
        $result = $this->processString($transliterator, $input);

        $this->assertEquals($input, $result, "Unmapped characters should remain unchanged");
    }

    public function testMixedIdeographicAnnotationsContent(): void
    {
        $transliterator = new IdeographicAnnotationsTransliterator();

        $input = "数字㆒は一、㆓は二です";
        $expected = "数字一は一、二は二です";
        $result = $this->processString($transliterator, $input);

        $this->assertEquals($expected, $result, "Should convert ideographic annotations while preserving other characters");
    }

    public function testConsecutiveIdeographicAnnotations(): void
    {
        $transliterator = new IdeographicAnnotationsTransliterator();

        $input = "㆒㆓㆔㆕";
        $expected = "一二三四";
        $result = $this->processString($transliterator, $input);

        $this->assertEquals($expected, $result, "Should convert consecutive ideographic annotations");
    }

    public function testIdeographicAnnotationsInContext(): void
    {
        $transliterator = new IdeographicAnnotationsTransliterator();

        $input = "第㆒章から第㆓章まで";
        $expected = "第一章から第二章まで";
        $result = $this->processString($transliterator, $input);

        $this->assertEquals($expected, $result, "Should convert ideographic annotations in natural text context");
    }

    public function testDirectionalAnnotations(): void
    {
        $transliterator = new IdeographicAnnotationsTransliterator();

        $input = "㆖㆗㆘";
        $expected = "上中下";
        $result = $this->processString($transliterator, $input);

        $this->assertEquals($expected, $result, "Should convert directional ideographic annotations");
    }

    public function testElementalAnnotations(): void
    {
        $transliterator = new IdeographicAnnotationsTransliterator();

        $input = "㆝㆞㆟";
        $expected = "天地人";
        $result = $this->processString($transliterator, $input);

        $this->assertEquals($expected, $result, "Should convert elemental ideographic annotations (heaven, earth, person)");
    }

    public function testCyclicalAnnotations(): void
    {
        $transliterator = new IdeographicAnnotationsTransliterator();

        $input = "㆙㆚㆛㆜";
        $expected = "甲乙丙丁";
        $result = $this->processString($transliterator, $input);

        $this->assertEquals($expected, $result, "Should convert cyclical ideographic annotations");
    }

    public function testRegistryIntegration(): void
    {
        // Test that the transliterator can be created via registry
        $factory = TransliteratorRegistry::getTransliteratorFactory('ideographic-annotations');
        $transliterator = $factory([]);

        $input = "㆒";
        $expected = "一";
        $result = $this->processString($transliterator, $input);

        $this->assertEquals($expected, $result, "Registry integration failed");
    }

    public function testIteratorProperties(): void
    {
        $transliterator = new IdeographicAnnotationsTransliterator();

        $input = "㆒㆓㆔";
        $chars = Chars::buildCharArray($input);
        $result = $transliterator($chars);
        $this->assertEquals(['一', '二', '三', ''], array_map(static fn ($c) => $c->c, iterator_to_array($result)));
    }

    private function processString(TransliteratorInterface $transliterator, string $input): string
    {
        $chars = Chars::buildCharArray($input);
        return Chars::fromChars($transliterator($chars));
    }
}