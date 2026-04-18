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
    
    public function testReplaceProlongedMarksBetweenNonKanasOther(): void
    {
        $transliterator = new ProlongedSoundMarksTransliterator(['replaceProlongedMarksBetweenNonKanas' => true]);

        // PSM between non-kana OTHER chars
        $input = "漢\u{30FC}字";
        $expected = "漢\u{FF0D}字";
        $result = $this->processString($transliterator, $input);

        $this->assertEquals($expected, $result, "PSM between non-kana OTHER chars failed");
    }

    public function testReplaceProlongedMarksBetweenHalfwidthAlnums(): void
    {
        $transliterator = new ProlongedSoundMarksTransliterator(['replaceProlongedMarksBetweenNonKanas' => true]);

        // PSM between halfwidth alnums
        $input = "1\u{30FC}2";
        $expected = "1\u{002D}2";
        $result = $this->processString($transliterator, $input);

        $this->assertEquals($expected, $result, "PSM between halfwidth alnums failed");
    }

    public function testReplaceProlongedMarksBetweenFullwidthAlnums(): void
    {
        $transliterator = new ProlongedSoundMarksTransliterator(['replaceProlongedMarksBetweenNonKanas' => true]);

        // PSM between fullwidth alnums
        $input = "\u{FF11}\u{30FC}\u{FF12}";
        $expected = "\u{FF11}\u{FF0D}\u{FF12}";
        $result = $this->processString($transliterator, $input);

        $this->assertEquals($expected, $result, "PSM between fullwidth alnums failed");
    }

    public function testReplaceProlongedMarksAfterKanaNotReplaced(): void
    {
        $transliterator = new ProlongedSoundMarksTransliterator(['replaceProlongedMarksBetweenNonKanas' => true]);

        // PSM after kana not replaced
        $input = "カ\u{30FC}漢";
        $expected = "カ\u{30FC}漢";
        $result = $this->processString($transliterator, $input);

        $this->assertEquals($expected, $result, "PSM after kana should not be replaced");
    }

    public function testReplaceProlongedMarksBeforeKanaNotReplaced(): void
    {
        $transliterator = new ProlongedSoundMarksTransliterator(['replaceProlongedMarksBetweenNonKanas' => true]);

        // PSM before kana not replaced
        $input = "漢\u{30FC}カ";
        $expected = "漢\u{30FC}カ";
        $result = $this->processString($transliterator, $input);

        $this->assertEquals($expected, $result, "PSM before kana should not be replaced");
    }

    public function testConsecutiveProlongedMarksBetweenNonKanas(): void
    {
        $transliterator = new ProlongedSoundMarksTransliterator(['replaceProlongedMarksBetweenNonKanas' => true]);

        // Consecutive PSMs between non-kana
        $input = "漢\u{30FC}\u{30FC}\u{30FC}字";
        $expected = "漢\u{FF0D}\u{FF0D}\u{FF0D}字";
        $result = $this->processString($transliterator, $input);

        $this->assertEquals($expected, $result, "Consecutive PSMs between non-kana failed");
    }

    public function testConsecutiveProlongedMarksBeforeKana(): void
    {
        $transliterator = new ProlongedSoundMarksTransliterator(['replaceProlongedMarksBetweenNonKanas' => true]);

        // Consecutive PSMs before kana not replaced
        $input = "漢\u{30FC}\u{30FC}\u{30FC}カ";
        $expected = "漢\u{30FC}\u{30FC}\u{30FC}カ";
        $result = $this->processString($transliterator, $input);

        $this->assertEquals($expected, $result, "Consecutive PSMs before kana should not be replaced");
    }

    public function testTrailingProlongedMarksAfterFullwidthNonKana(): void
    {
        $transliterator = new ProlongedSoundMarksTransliterator(['replaceProlongedMarksBetweenNonKanas' => true]);

        // Trailing PSMs after fullwidth non-kana
        $input = "漢\u{30FC}\u{30FC}\u{30FC}";
        $expected = "漢\u{FF0D}\u{FF0D}\u{FF0D}";
        $result = $this->processString($transliterator, $input);

        $this->assertEquals($expected, $result, "Trailing PSMs after fullwidth non-kana failed");
    }

    public function testTrailingProlongedMarksAfterHalfwidthNonKana(): void
    {
        $transliterator = new ProlongedSoundMarksTransliterator(['replaceProlongedMarksBetweenNonKanas' => true]);

        // Trailing PSMs after halfwidth non-kana
        $input = "1\u{30FC}\u{30FC}\u{30FC}";
        $expected = "1\u{002D}\u{002D}\u{002D}";
        $result = $this->processString($transliterator, $input);

        $this->assertEquals($expected, $result, "Trailing PSMs after halfwidth non-kana failed");
    }

    public function testNonKanaOnlyPsmAfterAlnumBeforeKana(): void
    {
        $transliterator = new ProlongedSoundMarksTransliterator(['replaceProlongedMarksBetweenNonKanas' => true]);

        // Non-kana only, PSM after alnum before kana not replaced
        $input = "A\u{30FC}カ";
        $expected = "A\u{30FC}カ";
        $result = $this->processString($transliterator, $input);

        $this->assertEquals($expected, $result, "Non-kana only: PSM after alnum before kana should not be replaced");
    }

    public function testBothOptionsPsmAfterAlnumBeforeKana(): void
    {
        $transliterator = new ProlongedSoundMarksTransliterator([
            'replaceProlongedMarksFollowingAlnums' => true,
            'replaceProlongedMarksBetweenNonKanas' => true,
        ]);

        // Both options: PSM after alnum before kana replaced by alnum option
        $input = "A\u{30FC}カ";
        $expected = "A\u{002D}カ";
        $result = $this->processString($transliterator, $input);

        $this->assertEquals($expected, $result, "Both options: PSM after alnum before kana should be replaced");
    }

    private function processString(TransliteratorInterface $transliterator, string $input): string
    {
        $chars = Chars::buildCharArray($input);
        return Chars::fromChars($transliterator($chars));
    }
}