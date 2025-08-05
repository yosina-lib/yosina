<?php

declare(strict_types=1);

use PHPUnit\Framework\TestCase;

use Yosina\Yosina;
use Yosina\TransliteratorInterface;

/**
 * Test for KanjiOldNewTransliterator to verify it works with actual kanji characters.
 */
class KanjiOldNewTransliteratorTest extends TestCase
{
    public function testKanjiOldNewTransliterator(): void
    {
        // Test with a specific old kanji that should be replaced
        // Using 亞 (U+4E9E) with IVS selector which should map to 亜 (U+4E9C) with IVS
        $oldKanji = "\u{4E9E}\u{E0100}"; // 亞 with IVS selector
        $expectedNewKanji = "\u{4E9C}\u{E0100}"; // 亜 with IVS selector
        
        $transliterator = Yosina::makeTransliterator([
            ['kanji-old-new', []]
        ]);
        
        $result = $transliterator($oldKanji);
        
        
        $this->assertEquals($expectedNewKanji, $result, "Kanji transliterator should convert old to new form");
    }
    
    public function testKanjiWithRegularText(): void
    {
        // Test mixed text with both regular characters and kanji
        $input = "Hello \u{4E9E}\u{E0100} World"; // Contains old kanji 亞 with IVS
        $expected = "Hello \u{4E9C}\u{E0100} World"; // Should contain new kanji 亜 with IVS
        
        $transliterator = Yosina::makeTransliterator([
            ['kanji-old-new', []]
        ]);
        
        $result = $transliterator($input);
        
        
        $this->assertEquals($expected, $result, "Mixed text kanji conversion failed");
    }
    
    public function testKanjiWithNoMapping(): void
    {
        // Test with a character that has no kanji mapping
        $input = "Hello 世界"; // Regular kanji without IVS that shouldn't be changed
        
        $transliterator = Yosina::makeTransliterator([
            ['kanji-old-new', []]
        ]);
        
        $result = $transliterator($input);
        
        
        $this->assertEquals($input, $result, "Text without kanji mappings should remain unchanged");
    }
}