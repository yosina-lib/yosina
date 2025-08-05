<?php

declare(strict_types=1);

use PHPUnit\Framework\TestCase;

use Yosina\Chars;
use Yosina\TransliteratorInterface;
use Yosina\TransliteratorRegistry;
use Yosina\Transliterators\Jisx0201AndAlikeTransliterator;

/**
 * Tests for Jisx0201AndAlikeTransliterator based on Java test cases.
 */
class Jisx0201AndAlikeTransliteratorTest extends TestCase
{
    public function testFullwidthToHalfwidthAlphabetic(): void
    {
        $transliterator = new Jisx0201AndAlikeTransliterator(['fullwidthToHalfwidth' => true]);
        
        // Test fullwidth alphabet to halfwidth
        $input = "ＡＢＣａｂｃ"; // Fullwidth A-C, a-c
        $expected = "ABCabc"; // Halfwidth equivalents
        $result = $this->processString($transliterator, $input);
        
        
        $this->assertEquals($expected, $result, "Fullwidth to halfwidth alphabetic conversion failed");
    }
    
    public function testFullwidthToHalfwidthNumeric(): void
    {
        $transliterator = new Jisx0201AndAlikeTransliterator(['fullwidthToHalfwidth' => true]);
        
        // Test fullwidth numbers to halfwidth
        $input = "０１２３４５６７８９"; // Fullwidth 0-9
        $expected = "0123456789"; // Halfwidth equivalents
        $result = $this->processString($transliterator, $input);
        
        
        $this->assertEquals($expected, $result, "Fullwidth to halfwidth numeric conversion failed");
    }
    
    public function testFullwidthToHalfwidthKatakana(): void
    {
        $transliterator = new Jisx0201AndAlikeTransliterator(['fullwidthToHalfwidth' => true]);
        
        // Test fullwidth katakana to halfwidth
        $input = "アイウエオカキクケコ"; // Fullwidth katakana
        $expected = "ｱｲｳｴｵｶｷｸｹｺ"; // Halfwidth katakana
        $result = $this->processString($transliterator, $input);
        
        
        $this->assertEquals($expected, $result, "Fullwidth to halfwidth katakana conversion failed");
    }
    
    public function testVoicedSoundMarks(): void
    {
        $transliterator = new Jisx0201AndAlikeTransliterator(['fullwidthToHalfwidth' => true]);
        
        // Test voiced katakana conversion
        $input = "ガギグゲゴ"; // Voiced katakana
        $expected = "ｶﾞｷﾞｸﾞｹﾞｺﾞ"; // Base + voiced mark
        $result = $this->processString($transliterator, $input);
        
        
        $this->assertEquals($expected, $result, "Voiced sound marks conversion failed");
    }
    
    public function testSemiVoicedSoundMarks(): void
    {
        $transliterator = new Jisx0201AndAlikeTransliterator(['fullwidthToHalfwidth' => true]);
        
        // Test semi-voiced katakana conversion
        $input = "パピプペポ"; // Semi-voiced katakana
        $expected = "ﾊﾟﾋﾟﾌﾟﾍﾟﾎﾟ"; // Base + semi-voiced mark
        $result = $this->processString($transliterator, $input);
        
        
        $this->assertEquals($expected, $result, "Semi-voiced sound marks conversion failed");
    }
    
    public function testHalfwidthToFullwidth(): void
    {
        $transliterator = new Jisx0201AndAlikeTransliterator(['fullwidthToHalfwidth' => false]);
        
        // Test halfwidth to fullwidth conversion
        $input = "ABCabc123"; // Halfwidth
        $expected = "ＡＢＣａｂｃ１２３"; // Fullwidth
        $result = $this->processString($transliterator, $input);
        
        
        $this->assertEquals($expected, $result, "Halfwidth to fullwidth conversion failed");
    }
    
    public function testHalfwidthKatakanaToFullwidth(): void
    {
        $transliterator = new Jisx0201AndAlikeTransliterator(['fullwidthToHalfwidth' => false]);
        
        // Test halfwidth katakana to fullwidth
        $input = "ｱｲｳｴｵ"; // Halfwidth katakana
        $expected = "アイウエオ"; // Fullwidth katakana
        $result = $this->processString($transliterator, $input);
        
        
        $this->assertEquals($expected, $result, "Halfwidth katakana to fullwidth conversion failed");
    }
    
    public function testVoicedMarksComposition(): void
    {
        $transliterator = new Jisx0201AndAlikeTransliterator([
            'fullwidthToHalfwidth' => false,
            'combineVoicedSoundMarks' => true
        ]);
        
        // Test combining voiced marks back to composed forms
        $input = "ｶﾞｷﾞｸﾞ"; // Base + voiced mark
        $expected = "ガギグ"; // Composed voiced katakana
        $result = $this->processString($transliterator, $input);
        
        
        $this->assertEquals($expected, $result, "Voiced marks composition failed");
    }
    
    public function testHiraganaConversion(): void
    {
        $transliterator = new Jisx0201AndAlikeTransliterator(['fullwidthToHalfwidth' => true, 'convertHiraganas' => true]);
        
        // Test hiragana to halfwidth katakana
        $input = "あいうえお"; // Hiragana
        $expected = "ｱｲｳｴｵ"; // Halfwidth katakana
        $result = $this->processString($transliterator, $input);
        
        
        $this->assertEquals($expected, $result, "Hiragana conversion failed");
    }
    
    public function testMixedContent(): void
    {
        $transliterator = new Jisx0201AndAlikeTransliterator(['fullwidthToHalfwidth' => true]);
        
        // Test mixed content: ASCII, fullwidth, katakana, other
        $input = "Hello ＡＢＣ アイウ 世界"; // Mixed content
        $expected = "Hello ABC ｱｲｳ 世界"; // Converted where applicable
        $result = $this->processString($transliterator, $input);
        
        
        $this->assertEquals($expected, $result, "Mixed content conversion failed");
    }
    
    public function testSpecialSymbols(): void
    {
        $transliterator = new Jisx0201AndAlikeTransliterator(['fullwidthToHalfwidth' => true]);
        
        // Test special symbols conversion
        $input = "！＂＃％＆（）"; // Fullwidth symbols
        $expected = "!\"#%&()"; // Halfwidth symbols
        $result = $this->processString($transliterator, $input);
        
        
        $this->assertEquals($expected, $result, "Special symbols conversion failed");
    }
    
    public function testYenSignOption(): void
    {
        // Test with yen sign conversion enabled
        $transliterator = new Jisx0201AndAlikeTransliterator([
            'fullwidthToHalfwidth' => true,
            'u005cAsYenSign' => true
        ]);
        
        $input = "￥"; // Fullwidth yen sign
        $expected = "\\"; // Backslash
        $result = $this->processString($transliterator, $input);
        
        
        $this->assertEquals($expected, $result, "Yen sign conversion failed");
    }
    
    public function testNoConversion(): void
    {
        $transliterator = new Jisx0201AndAlikeTransliterator(['fullwidthToHalfwidth' => true]);
        
        // Test characters that should not be converted
        $input = "漢字 ひらがな 🎌"; // Kanji, hiragana, emoji
        $expected = "漢字 ひらがな 🎌"; // Should remain unchanged
        $result = $this->processString($transliterator, $input);
        
        
        $this->assertEquals($expected, $result, "Non-convertible characters changed unexpectedly");
    }
    
    public function testEmptyString(): void
    {
        $transliterator = new Jisx0201AndAlikeTransliterator(['fullwidthToHalfwidth' => true]);
        
        $input = "";
        $expected = "";
        $result = $this->processString($transliterator, $input);
        
        
        $this->assertEquals($expected, $result, "Empty string handling failed");
    }
    
    public function testComplexVoicedConversion(): void
    {
        $transliterator = new Jisx0201AndAlikeTransliterator(['fullwidthToHalfwidth' => true]);
        
        // Test complex voiced sound conversion
        $input = "ザジズゼゾダヂヅデド"; // Voiced Z and D sounds
        $expected = "ｻﾞｼﾞｽﾞｾﾞｿﾞﾀﾞﾁﾞﾂﾞﾃﾞﾄﾞ"; // Base + voiced marks
        $result = $this->processString($transliterator, $input);
        
        
        $this->assertEquals($expected, $result, "Complex voiced conversion failed");
    }
    
    public function testRegistryIntegration(): void
    {
        // Test that the transliterator can be created via registry
        $factory = TransliteratorRegistry::getTransliteratorFactory('jisx0201-and-alike');
        $transliterator = $factory(['fullwidthToHalfwidth' => true]);
        
        $input = "ＡＢＣ";
        $expected = "ABC";
        $result = $this->processString($transliterator, $input);
        
        
        $this->assertEquals($expected, $result, "Registry integration failed");
    }
    
    private function processString(TransliteratorInterface $transliterator, string $input): string
    {
        $chars = Chars::buildCharArray($input);
        return Chars::fromChars($transliterator($chars));
    }
    
}