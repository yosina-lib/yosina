<?php

declare(strict_types=1);

use PHPUnit\Framework\TestCase;

use Yosina\Chars;
use Yosina\TransliteratorInterface;
use Yosina\TransliteratorRegistry;
use Yosina\Transliterators\ProlongedSoundMarksTransliterator;

/**
 * Tests for ProlongedSoundMarksTransliterator based on Java test cases.
 */
class ProlongedSoundMarksTransliteratorTest extends TestCase
{
    public function testBasicHiraganaConversion(): void
    {
        $transliterator = new ProlongedSoundMarksTransliterator();
        
        // Test hiragana with ASCII hyphen
        $input = "あ-"; // hiragana + ASCII hyphen
        $expected = "あー"; // hiragana + prolonged sound mark
        $result = $this->processString($transliterator, $input);
        
        
        $this->assertEquals($expected, $result, "Basic hiragana conversion failed");
    }
    
    public function testBasicKatakanaConversion(): void
    {
        $transliterator = new ProlongedSoundMarksTransliterator();
        
        // Test katakana with ASCII hyphen
        $input = "ア-"; // katakana + ASCII hyphen
        $expected = "アー"; // katakana + prolonged sound mark
        $result = $this->processString($transliterator, $input);
        
        
        $this->assertEquals($expected, $result, "Basic katakana conversion failed");
    }
    
    public function testHalfwidthKatakanaConversion(): void
    {
        $transliterator = new ProlongedSoundMarksTransliterator();
        
        // Test halfwidth katakana with ASCII hyphen
        $input = "ｱ-"; // halfwidth katakana + ASCII hyphen
        $expected = "ｱｰ"; // halfwidth katakana + halfwidth prolonged sound mark
        $result = $this->processString($transliterator, $input);
        
        
        $this->assertEquals($expected, $result, "Halfwidth katakana conversion failed");
    }
    
    public function testVariousHyphenTypes(): void
    {
        $transliterator = new ProlongedSoundMarksTransliterator();
        
        // Test different types of hyphens that are supported
        $testCases = [
            ["ア\u{002d}", "アー"], // ASCII hyphen-minus
            ["ア\u{ff0d}", "アー"], // Fullwidth hyphen-minus  
            ["ア\u{2010}", "アー"], // Hyphen
            ["ア\u{2014}", "アー"], // Em dash
            ["ア\u{2015}", "アー"], // Horizontal bar
            ["ア\u{2212}", "アー"], // Minus sign
        ];
        
        foreach ($testCases as [$input, $expected]) {
            $result = $this->processString($transliterator, $input);
            $this->assertEquals($expected, $result, "Hyphen type conversion failed for: $input");
        }
    }
    
    public function testNoConversionAfterNonJapanese(): void
    {
        $transliterator = new ProlongedSoundMarksTransliterator();
        
        // Test that hyphens after non-Japanese characters are not converted
        $input = "Hello-World"; // English with hyphen
        $expected = "Hello-World"; // Should remain unchanged
        $result = $this->processString($transliterator, $input);
        
        
        $this->assertEquals($expected, $result, "Non-Japanese context conversion failed");
    }
    
    public function testSokuonHandling(): void
    {
        $transliterator = new ProlongedSoundMarksTransliterator(['allowProlongedSokuon' => false]);
        
        // Test sokuon (っ/ッ) - should not be prolonged by default
        $input = "ウッ-"; // katakana + sokuon + hyphen
        $expected = "ウッ-"; // Should remain unchanged
        $result = $this->processString($transliterator, $input);
        
        
        $this->assertEquals($expected, $result, "Sokuon handling failed");
    }
    
    public function testSokuonProlongationEnabled(): void
    {
        $transliterator = new ProlongedSoundMarksTransliterator(['allowProlongedSokuon' => true]);
        
        // Test sokuon prolongation when enabled
        $input = "ウッ-"; // katakana + sokuon + hyphen
        $expected = "ウッー"; // Should convert
        $result = $this->processString($transliterator, $input);
        
        
        $this->assertEquals($expected, $result, "Sokuon prolongation failed");
    }
    
    public function testHatsuonHandling(): void
    {
        $transliterator = new ProlongedSoundMarksTransliterator(['allowProlongedHatsuon' => false]);
        
        // Test hatsuon (ん/ン) - should not be prolonged by default
        $input = "ウン-"; // katakana + hatsuon + hyphen
        $expected = "ウン-"; // Should remain unchanged
        $result = $this->processString($transliterator, $input);
        
        
        $this->assertEquals($expected, $result, "Hatsuon handling failed");
    }
    
    public function testHatsuonProlongationEnabled(): void
    {
        $transliterator = new ProlongedSoundMarksTransliterator(['allowProlongedHatsuon' => true]);
        
        // Test hatsuon prolongation when enabled
        $input = "アン-"; // katakana + hatsuon + hyphen
        $expected = "アンー"; // Should convert
        $result = $this->processString($transliterator, $input);
        
        
        $this->assertEquals($expected, $result, "Hatsuon prolongation failed");
    }
    
    public function testProlongedMarkToHyphen(): void
    {
        $transliterator = new ProlongedSoundMarksTransliterator(['replaceProlongedMarksFollowingAlnums' => true]);
        
        // Test converting prolonged sound marks back to hyphens between alphanumerics
        $input = "Aー1"; // Letter + prolonged mark + number
        $expected = "A-1"; // Should convert to hyphen
        $result = $this->processString($transliterator, $input);
        
        
        $this->assertEquals($expected, $result, "Prolonged mark to hyphen conversion failed");
    }
    
    public function testMixedContent(): void
    {
        $transliterator = new ProlongedSoundMarksTransliterator();
        
        // Test mixed Japanese and non-Japanese content
        $input = "Hello カ- World あ- End"; // Mixed content
        $expected = "Hello カー World あー End"; // Only Japanese parts converted
        $result = $this->processString($transliterator, $input);
        
        
        $this->assertEquals($expected, $result, "Mixed content conversion failed");
    }
    
    public function testConsecutiveHyphens(): void
    {
        $transliterator = new ProlongedSoundMarksTransliterator();
        
        // Test multiple consecutive hyphens
        $input = "ア--"; // katakana + double hyphen
        $expected = "アーー"; // Double prolonged sound mark
        $result = $this->processString($transliterator, $input);
        
        
        $this->assertEquals($expected, $result, "Consecutive hyphens conversion failed");
    }
    
    public function testWordBoundaries(): void
    {
        $transliterator = new ProlongedSoundMarksTransliterator();
        
        // Test word boundaries and spaces
        $input = "カ- ア-"; // Two separate words with hyphens
        $expected = "カー アー"; // Both should be converted
        $result = $this->processString($transliterator, $input);
        
        
        $this->assertEquals($expected, $result, "Word boundaries conversion failed");
    }
    
    public function testEmptyString(): void
    {
        $transliterator = new ProlongedSoundMarksTransliterator();
        
        $input = "";
        $expected = "";
        $result = $this->processString($transliterator, $input);
        
        
        $this->assertEquals($expected, $result, "Empty string handling failed");
    }
    
    public function testHyphenAtStart(): void
    {
        $transliterator = new ProlongedSoundMarksTransliterator();
        
        // Test hyphen at start of string
        $input = "-アイ"; // hyphen at start
        $expected = "-アイ"; // Should remain unchanged
        $result = $this->processString($transliterator, $input);
        
        
        $this->assertEquals($expected, $result, "Hyphen at start handling failed");
    }
    
    public function testComplexScenario(): void
    {
        $transliterator = new ProlongedSoundMarksTransliterator([
            'allowProlongedSokuon' => true,
            'allowProlongedHatsuon' => true,
            'replaceProlongedMarksFollowingAlnums' => true
        ]);
        
        // Test complex scenario with all options enabled
        $input = "カ-ッ-ン- Aー1 ｱ-"; // Complex mix
        $expected = "カーッーンー A-1 ｱｰ"; // Expected result
        $result = $this->processString($transliterator, $input);
        
        
        $this->assertEquals($expected, $result, "Complex scenario conversion failed");
    }
    
    public function testRegistryIntegration(): void
    {
        // Test that the transliterator can be created via registry
        $factory = TransliteratorRegistry::getTransliteratorFactory('prolonged-sound-marks');
        $transliterator = $factory([]);
        
        $input = "ア-";
        $expected = "アー";
        $result = $this->processString($transliterator, $input);
        
        
        $this->assertEquals($expected, $result, "Registry integration failed");
    }
    
    private function processString(TransliteratorInterface $transliterator, string $input): string
    {
        $chars = Chars::buildCharArray($input);
        return Chars::fromChars($transliterator($chars));
    }
}