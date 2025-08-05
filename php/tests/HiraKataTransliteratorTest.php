<?php

declare(strict_types=1);

use PHPUnit\Framework\TestCase;
use Yosina\Chars;
use Yosina\TransliteratorInterface;
use Yosina\TransliteratorRegistry;
use Yosina\Transliterators\HiraKataTransliterator;

/**
 * Tests for HiraKataTransliterator
 */
class HiraKataTransliteratorTest extends TestCase
{
    public function testHiraToKataBasic(): void
    {
        $transliterator = new HiraKataTransliterator(['mode' => HiraKataTransliterator::MODE_HIRA_TO_KATA]);
        
        $this->assertEquals("アイウエオ", $this->processString($transliterator, "あいうえお"));
        $this->assertEquals("ガギグゲゴ", $this->processString($transliterator, "がぎぐげご"));
        $this->assertEquals("パピプペポ", $this->processString($transliterator, "ぱぴぷぺぽ"));
    }

    public function testHiraToKataSmallCharacters(): void
    {
        $transliterator = new HiraKataTransliterator(['mode' => HiraKataTransliterator::MODE_HIRA_TO_KATA]);
        
        $this->assertEquals("ァィゥェォッャュョ", $this->processString($transliterator, "ぁぃぅぇぉっゃゅょ"));
        $this->assertEquals("ヮヵヶ", $this->processString($transliterator, "ゎゕゖ"));
    }

    public function testHiraToKataMixedText(): void
    {
        $transliterator = new HiraKataTransliterator(['mode' => HiraKataTransliterator::MODE_HIRA_TO_KATA]);
        
        $this->assertEquals("アイウエオ123ABCアイウエオ", $this->processString($transliterator, "あいうえお123ABCアイウエオ"));
        $this->assertEquals("コンニチハ、世界！", $this->processString($transliterator, "こんにちは、世界！"));
    }

    public function testHiraToKataAllCharacters(): void
    {
        $transliterator = new HiraKataTransliterator(['mode' => HiraKataTransliterator::MODE_HIRA_TO_KATA]);
        
        $input = "あいうえおかきくけこさしすせそたちつてとなにぬねのはひふへほまみむめもやゆよらりるれろわをんがぎぐげござじずぜぞだぢづでどばびぶべぼぱぴぷぺぽゔ";
        $expected = "アイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヲンガギグゲゴザジズゼゾダヂヅデドバビブベボパピプペポヴ";
        
        $this->assertEquals($expected, $this->processString($transliterator, $input));
    }

    public function testHiraToKataWiWe(): void
    {
        $transliterator = new HiraKataTransliterator(['mode' => HiraKataTransliterator::MODE_HIRA_TO_KATA]);
        
        $this->assertEquals("ヰヱ", $this->processString($transliterator, "ゐゑ"));
    }

    public function testKataToHiraBasic(): void
    {
        $transliterator = new HiraKataTransliterator(['mode' => HiraKataTransliterator::MODE_KATA_TO_HIRA]);
        
        $this->assertEquals("あいうえお", $this->processString($transliterator, "アイウエオ"));
        $this->assertEquals("がぎぐげご", $this->processString($transliterator, "ガギグゲゴ"));
        $this->assertEquals("ぱぴぷぺぽ", $this->processString($transliterator, "パピプペポ"));
    }

    public function testKataToHiraSmallCharacters(): void
    {
        $transliterator = new HiraKataTransliterator(['mode' => HiraKataTransliterator::MODE_KATA_TO_HIRA]);
        
        $this->assertEquals("ぁぃぅぇぉっゃゅょ", $this->processString($transliterator, "ァィゥェォッャュョ"));
        $this->assertEquals("ゎゕゖ", $this->processString($transliterator, "ヮヵヶ"));
    }

    public function testKataToHiraMixedText(): void
    {
        $transliterator = new HiraKataTransliterator(['mode' => HiraKataTransliterator::MODE_KATA_TO_HIRA]);
        
        $this->assertEquals("あいうえお123ABCあいうえお", $this->processString($transliterator, "アイウエオ123ABCあいうえお"));
        $this->assertEquals("こんにちは、世界！", $this->processString($transliterator, "コンニチハ、世界！"));
    }

    public function testKataToHiraVu(): void
    {
        $transliterator = new HiraKataTransliterator(['mode' => HiraKataTransliterator::MODE_KATA_TO_HIRA]);
        
        $this->assertEquals("ゔ", $this->processString($transliterator, "ヴ"));
    }

    public function testKataToHiraSpecialKatakana(): void
    {
        $transliterator = new HiraKataTransliterator(['mode' => HiraKataTransliterator::MODE_KATA_TO_HIRA]);
        
        // Special katakana without hiragana equivalents should remain unchanged
        $this->assertEquals("ヷヸヹヺ", $this->processString($transliterator, "ヷヸヹヺ"));
    }

    public function testKataToHiraAllCharacters(): void
    {
        $transliterator = new HiraKataTransliterator(['mode' => HiraKataTransliterator::MODE_KATA_TO_HIRA]);
        
        $input = "アイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヲンガギグゲゴザジズゼゾダヂヅデドバビブベボパピプペポヴ";
        $expected = "あいうえおかきくけこさしすせそたちつてとなにぬねのはひふへほまみむめもやゆよらりるれろわをんがぎぐげござじずぜぞだぢづでどばびぶべぼぱぴぷぺぽゔ";
        
        $this->assertEquals($expected, $this->processString($transliterator, $input));
    }

    public function testKataToHiraWiWe(): void
    {
        $transliterator = new HiraKataTransliterator(['mode' => HiraKataTransliterator::MODE_KATA_TO_HIRA]);
        
        $this->assertEquals("ゐゑ", $this->processString($transliterator, "ヰヱ"));
    }

    public function testDefaultMode(): void
    {
        // Test that default mode is hira to kata
        $transliterator = new HiraKataTransliterator();
        
        $this->assertEquals("アイウエオ", $this->processString($transliterator, "あいうえお"));
    }

    public function testCachingBehavior(): void
    {
        // First transliterator builds the cache
        $transliterator1 = new HiraKataTransliterator(['mode' => HiraKataTransliterator::MODE_HIRA_TO_KATA]);
        $this->assertEquals("アイウエオ", $this->processString($transliterator1, "あいうえお"));
        
        // Second transliterator should use cached table
        $transliterator2 = new HiraKataTransliterator(['mode' => HiraKataTransliterator::MODE_HIRA_TO_KATA]);
        $this->assertEquals("カキクケコ", $this->processString($transliterator2, "かきくけこ"));
        
        // Test kata to hira mode caching
        $transliterator3 = new HiraKataTransliterator(['mode' => HiraKataTransliterator::MODE_KATA_TO_HIRA]);
        $this->assertEquals("あいうえお", $this->processString($transliterator3, "アイウエオ"));
    }

    public function testRegistryIntegration(): void
    {
        // Test that the transliterator can be created via registry
        $factory = TransliteratorRegistry::getTransliteratorFactory('hira-kata');
        $transliterator = $factory([]);
        
        $this->assertEquals("アイウエオ", $this->processString($transliterator, "あいうえお"));
    }

    private function processString(TransliteratorInterface $transliterator, string $input): string
    {
        $chars = Chars::buildCharArray($input);
        return Chars::fromChars($transliterator($chars));
    }
}