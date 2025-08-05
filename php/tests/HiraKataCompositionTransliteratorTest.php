<?php

declare(strict_types=1);

use PHPUnit\Framework\TestCase;
use Yosina\Chars;
use Yosina\TransliteratorInterface;
use Yosina\TransliteratorRegistry;
use Yosina\Transliterators\HiraKataCompositionTransliterator;

/**
 * Tests for HiraKataCompositionTransliterator based on Java test cases.
 */
class HiraKataCompositionTransliteratorTest extends TestCase
{
    public function testBasicHiraganaComposition(): void
    {
        $transliterator = new HiraKataCompositionTransliterator();
        
        // Test basic hiragana with combining voiced sound mark (dakuten)
        $input = "か\u{3099}"; // か + combining voiced sound mark
        $expected = "が"; // composed が
        $result = $this->processString($transliterator, $input);
        
        
        $this->assertEquals($expected, $result, "Basic hiragana composition failed");
    }
    
    public function testBasicKatakanaComposition(): void
    {
        $transliterator = new HiraKataCompositionTransliterator();
        
        // Test basic katakana with combining voiced sound mark
        $input = "カ\u{3099}"; // カ + combining voiced sound mark
        $expected = "ガ"; // composed ガ
        $result = $this->processString($transliterator, $input);
        
        
        $this->assertEquals($expected, $result, "Basic katakana composition failed");
    }
    
    public function testHandakutenComposition(): void
    {
        $transliterator = new HiraKataCompositionTransliterator();
        
        // Test hiragana with combining semi-voiced sound mark (handakuten)
        $input = "は\u{309a}"; // は + combining semi-voiced sound mark
        $expected = "ぱ"; // composed ぱ
        $result = $this->processString($transliterator, $input);
        
        
        $this->assertEquals($expected, $result, "Handakuten composition failed");
    }
    
    public function testSpecialCharacters(): void
    {
        $transliterator = new HiraKataCompositionTransliterator();
        
        // Test special characters: う + dakuten = ゔ (VU sound)
        $input = "う\u{3099}"; // う + combining voiced sound mark
        $expected = "ゔ"; // composed ゔ
        $result = $this->processString($transliterator, $input);
        
        
        $this->assertEquals($expected, $result, "Special character composition failed");
        
        // Test katakana version: ウ + dakuten = ヴ
        $input2 = "ウ\u{3099}"; // ウ + combining voiced sound mark
        $expected2 = "ヴ"; // composed ヴ
        $result2 = $this->processString($transliterator, $input2);
        
        $this->assertEquals($expected2, $result2, "Special character composition failed");
    }
    
    public function testNonCombiningMarks(): void
    {
        $transliterator = new HiraKataCompositionTransliterator(['composeNonCombiningMarks' => true]);
        
        // Test with non-combining voiced sound mark (゛ U+309B)
        $input = "か\u{309b}"; // か + non-combining voiced sound mark
        $expected = "が"; // composed が
        $result = $this->processString($transliterator, $input);
        
        
        $this->assertEquals($expected, $result, "Non-combining marks composition failed");
    }
    
    public function testNonCombiningMarksDisabled(): void
    {
        $transliterator = new HiraKataCompositionTransliterator(['composeNonCombiningMarks' => false]);
        
        // Test with non-combining voiced sound mark should not compose
        $input = "か\u{309b}"; // か + non-combining voiced sound mark
        $expected = "か\u{309b}"; // should remain unchanged
        $result = $this->processString($transliterator, $input);
        
        
        $this->assertEquals($expected, $result, "Non-combining marks should not compose when disabled");
    }
    
    public function testMixedContent(): void
    {
        $transliterator = new HiraKataCompositionTransliterator();
        
        // Test mixed hiragana, katakana, and other characters
        $input = "Hello か\u{3099}ら カ\u{3099}ラ World";
        $expected = "Hello がら ガラ World";
        $result = $this->processString($transliterator, $input);
        
        
        $this->assertEquals($expected, $result, "Mixed content composition failed");
    }
    
    public function testSequentialComposition(): void
    {
        $transliterator = new HiraKataCompositionTransliterator();
        
        // Test multiple compositions in sequence
        $input = "か\u{3099}き\u{3099}く\u{3099}"; // がぎぐ
        $expected = "がぎぐ"; // composed forms
        $result = $this->processString($transliterator, $input);
        
        
        $this->assertEquals($expected, $result, "Sequential composition failed");
    }
    
    public function testNoComposition(): void
    {
        $transliterator = new HiraKataCompositionTransliterator();
        
        // Test characters that should not be composed
        $input = "Hello World 123";
        $expected = "Hello World 123";
        $result = $this->processString($transliterator, $input);
        
        
        $this->assertEquals($expected, $result, "Non-composable characters changed unexpectedly");
    }
    
    public function testEmptyString(): void
    {
        $transliterator = new HiraKataCompositionTransliterator();
        
        $input = "";
        $expected = "";
        $result = $this->processString($transliterator, $input);
        
        
        $this->assertEquals($expected, $result, "Empty string handling failed");
    }
    
    public function testDanglingMarks(): void
    {
        $transliterator = new HiraKataCompositionTransliterator();
        
        // Test combining marks without base characters
        $input = "\u{3099}\u{309a}"; // just combining marks
        $expected = "\u{3099}\u{309a}"; // should remain unchanged
        $result = $this->processString($transliterator, $input);
        
        
        $this->assertEquals($expected, $result, "Dangling marks handling failed");
    }
    
    public function testIterationMarks(): void
    {
        $transliterator = new HiraKataCompositionTransliterator();
        
        // Test hiragana iteration mark
        $input1 = "\u{309d}\u{3099}"; // ゝ + combining voiced sound mark
        $expected1 = "\u{309e}"; // ゞ
        $result1 = $this->processString($transliterator, $input1);
        $this->assertEquals($expected1, $result1, "Hiragana iteration mark composition failed");
        
        // Test katakana iteration mark
        $input2 = "\u{30fd}\u{3099}"; // ヽ + combining voiced sound mark
        $expected2 = "\u{30fe}"; // ヾ
        $result2 = $this->processString($transliterator, $input2);
        $this->assertEquals($expected2, $result2, "Katakana iteration mark composition failed");
        
        // Test vertical hiragana iteration mark
        $input3 = "\u{3031}\u{3099}"; // 〱 + combining voiced sound mark
        $expected3 = "\u{3032}"; // 〲
        $result3 = $this->processString($transliterator, $input3);
        $this->assertEquals($expected3, $result3, "Vertical hiragana iteration mark composition failed");
        
        // Test vertical katakana iteration mark
        $input4 = "\u{3033}\u{3099}"; // 〳 + combining voiced sound mark
        $expected4 = "\u{3034}"; // 〴
        $result4 = $this->processString($transliterator, $input4);
        $this->assertEquals($expected4, $result4, "Vertical katakana iteration mark composition failed");
    }
    
    public function testSpecialKatakanaWithDakuten(): void
    {
        $transliterator = new HiraKataCompositionTransliterator();
        
        // Test ワ + ゛ → ヷ
        $input1 = "\u{30ef}\u{3099}";
        $expected1 = "\u{30f7}";
        $result1 = $this->processString($transliterator, $input1);
        $this->assertEquals($expected1, $result1, "ワ + dakuten composition failed");
        
        // Test ヰ + ゛ → ヸ
        $input2 = "\u{30f0}\u{3099}";
        $expected2 = "\u{30f8}";
        $result2 = $this->processString($transliterator, $input2);
        $this->assertEquals($expected2, $result2, "ヰ + dakuten composition failed");
        
        // Test ヱ + ゛ → ヹ
        $input3 = "\u{30f1}\u{3099}";
        $expected3 = "\u{30f9}";
        $result3 = $this->processString($transliterator, $input3);
        $this->assertEquals($expected3, $result3, "ヱ + dakuten composition failed");
        
        // Test ヲ + ゛ → ヺ
        $input4 = "\u{30f2}\u{3099}";
        $expected4 = "\u{30fa}";
        $result4 = $this->processString($transliterator, $input4);
        $this->assertEquals($expected4, $result4, "ヲ + dakuten composition failed");
    }
    
    public function testIterationMarksWithNonCombining(): void
    {
        $transliterator = new HiraKataCompositionTransliterator(['composeNonCombiningMarks' => true]);
        
        // Test hiragana iteration mark with non-combining voiced mark
        $input1 = "\u{309d}\u{309b}"; // ゝ + ゛ (non-combining)
        $expected1 = "\u{309e}"; // ゞ
        $result1 = $this->processString($transliterator, $input1);
        $this->assertEquals($expected1, $result1, "Hiragana iteration mark with non-combining failed");
        
        // Test katakana iteration mark with non-combining voiced mark
        $input2 = "\u{30fd}\u{309b}"; // ヽ + ゛ (non-combining)
        $expected2 = "\u{30fe}"; // ヾ
        $result2 = $this->processString($transliterator, $input2);
        $this->assertEquals($expected2, $result2, "Katakana iteration mark with non-combining failed");
        
        // Test vertical hiragana iteration mark with non-combining voiced mark
        $input3 = "\u{3031}\u{309b}"; // 〱 + ゛ (non-combining)
        $expected3 = "\u{3032}"; // 〲
        $result3 = $this->processString($transliterator, $input3);
        $this->assertEquals($expected3, $result3, "Vertical hiragana iteration mark with non-combining failed");
        
        // Test vertical katakana iteration mark with non-combining voiced mark
        $input4 = "\u{3033}\u{309b}"; // 〳 + ゛ (non-combining)
        $expected4 = "\u{3034}"; // 〴
        $result4 = $this->processString($transliterator, $input4);
        $this->assertEquals($expected4, $result4, "Vertical katakana iteration mark with non-combining failed");
    }
    
    public function testMixedTextWithIterationMarks(): void
    {
        $transliterator = new HiraKataCompositionTransliterator();
        
        $input = "テスト\u{309d}\u{3099}カタカナ\u{30fd}\u{3099}";
        $expected = "テスト\u{309e}カタカナ\u{30fe}";
        $result = $this->processString($transliterator, $input);
        
        $this->assertEquals($expected, $result, "Mixed text with iteration marks failed");
    }
    
    public function testRegistryIntegration(): void
    {
        // Test that the transliterator can be created via registry
        $factory = TransliteratorRegistry::getTransliteratorFactory('hira-kata-composition');
        $transliterator = $factory([]);
        
        $input = "か\u{3099}";
        $expected = "が";
        $result = $this->processString($transliterator, $input);
        
        
        $this->assertEquals($expected, $result, "Registry integration failed");
    }
    
    private function processString(TransliteratorInterface $transliterator, string $input): string
    {
        $chars = Chars::buildCharArray($input);
        return Chars::fromChars($transliterator($chars));
    }
    
}