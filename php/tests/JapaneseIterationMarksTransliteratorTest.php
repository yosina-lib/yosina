<?php

declare(strict_types=1);

use PHPUnit\Framework\TestCase;

use Yosina\Chars;
use Yosina\TransliteratorInterface;
use Yosina\TransliteratorRegistry;
use Yosina\Transliterators\JapaneseIterationMarksTransliterator;

/**
 * Tests for JapaneseIterationMarksTransliterator.
 */
class JapaneseIterationMarksTransliteratorTest extends TestCase
{
    public function testBasicHiraganaRepetition(): void
    {
        $transliterator = new JapaneseIterationMarksTransliterator();
        
        // Basic hiragana repetition
        $input = "さゝ";
        $expected = "ささ";
        $result = $this->processString($transliterator, $input);
        $this->assertEquals($expected, $result, "Basic hiragana repetition failed");
        
        // Multiple hiragana repetitions
        $input = "みゝこゝろ";
        $expected = "みみこころ";
        $result = $this->processString($transliterator, $input);
        $this->assertEquals($expected, $result, "Multiple hiragana repetitions failed");
    }
    
    public function testHiraganaVoicedRepetition(): void
    {
        $transliterator = new JapaneseIterationMarksTransliterator();
        
        // Hiragana voiced repetition
        $input = "はゞ";
        $expected = "はば";
        $result = $this->processString($transliterator, $input);
        $this->assertEquals($expected, $result, "Hiragana voiced repetition failed");
        
        // Multiple voiced repetitions
        $input = "たゞしゞま";
        $expected = "ただしじま";
        $result = $this->processString($transliterator, $input);
        $this->assertEquals($expected, $result, "Multiple hiragana voiced repetitions failed");
    }
    
    public function testBasicKatakanaRepetition(): void
    {
        $transliterator = new JapaneseIterationMarksTransliterator();
        
        // Basic katakana repetition
        $input = "サヽ";
        $expected = "ササ";
        $result = $this->processString($transliterator, $input);
        $this->assertEquals($expected, $result, "Basic katakana repetition failed");
    }
    
    public function testKatakanaVoicedRepetition(): void
    {
        $transliterator = new JapaneseIterationMarksTransliterator();
        
        // Katakana voiced repetition
        $input = "ハヾ";
        $expected = "ハバ";
        $result = $this->processString($transliterator, $input);
        $this->assertEquals($expected, $result, "Katakana voiced repetition failed");
        
        // Special case: ウ with voicing
        $input = "ウヾ";
        $expected = "ウヴ";
        $result = $this->processString($transliterator, $input);
        $this->assertEquals($expected, $result, "Katakana ウ voicing failed");
    }
    
    public function testKanjiRepetition(): void
    {
        $transliterator = new JapaneseIterationMarksTransliterator();
        
        // Basic kanji repetition
        $input = "人々";
        $expected = "人人";
        $result = $this->processString($transliterator, $input);
        $this->assertEquals($expected, $result, "Basic kanji repetition failed");
        
        // Multiple kanji repetitions
        $input = "日々月々年々";
        $expected = "日日月月年年";
        $result = $this->processString($transliterator, $input);
        $this->assertEquals($expected, $result, "Multiple kanji repetitions failed");
        
        // Kanji in compound words
        $input = "色々";
        $expected = "色色";
        $result = $this->processString($transliterator, $input);
        $this->assertEquals($expected, $result, "Kanji in compound words failed");
    }
    
    public function testInvalidCombinations(): void
    {
        $transliterator = new JapaneseIterationMarksTransliterator();
        
        // Hiragana mark after katakana
        $input = "カゝ";
        $expected = "カゝ";
        $result = $this->processString($transliterator, $input);
        $this->assertEquals($expected, $result, "Hiragana mark after katakana should not change");
        
        // Katakana mark after hiragana
        $input = "かヽ";
        $expected = "かヽ";
        $result = $this->processString($transliterator, $input);
        $this->assertEquals($expected, $result, "Katakana mark after hiragana should not change");
        
        // Kanji mark after hiragana
        $input = "か々";
        $expected = "か々";
        $result = $this->processString($transliterator, $input);
        $this->assertEquals($expected, $result, "Kanji mark after hiragana should not change");
        
        // Iteration mark at start
        $input = "ゝあ";
        $expected = "ゝあ";
        $result = $this->processString($transliterator, $input);
        $this->assertEquals($expected, $result, "Iteration mark at start should not change");
    }
    
    public function testConsecutiveIterationMarks(): void
    {
        $transliterator = new JapaneseIterationMarksTransliterator();
        
        // Consecutive iteration marks - only first should be expanded
        $input = "さゝゝ";
        $expected = "ささゝ";
        $result = $this->processString($transliterator, $input);
        $this->assertEquals($expected, $result, "Consecutive iteration marks handling failed");
    }
    
    public function testNonRepeatableCharacters(): void
    {
        $transliterator = new JapaneseIterationMarksTransliterator();
        
        // Hiragana hatsuon can't repeat
        $input = "んゝ";
        $expected = "んゝ";
        $result = $this->processString($transliterator, $input);
        $this->assertEquals($expected, $result, "Hiragana hatsuon should not repeat");
        
        // Hiragana sokuon can't repeat
        $input = "っゝ";
        $expected = "っゝ";
        $result = $this->processString($transliterator, $input);
        $this->assertEquals($expected, $result, "Hiragana sokuon should not repeat");
        
        // Katakana hatsuon can't repeat
        $input = "ンヽ";
        $expected = "ンヽ";
        $result = $this->processString($transliterator, $input);
        $this->assertEquals($expected, $result, "Katakana hatsuon should not repeat");
        
        // Katakana sokuon can't repeat
        $input = "ッヽ";
        $expected = "ッヽ";
        $result = $this->processString($transliterator, $input);
        $this->assertEquals($expected, $result, "Katakana sokuon should not repeat");
        
        // Voiced character can't voice again
        $input = "がゞ";
        $expected = "がゞ";
        $result = $this->processString($transliterator, $input);
        $this->assertEquals($expected, $result, "Voiced character should not voice again");
        
        // Semi-voiced character can't voice
        $input = "ぱゞ";
        $expected = "ぱゞ";
        $result = $this->processString($transliterator, $input);
        $this->assertEquals($expected, $result, "Semi-voiced character should not voice");
    }
    
    public function testMixedText(): void
    {
        $transliterator = new JapaneseIterationMarksTransliterator();
        
        // Mixed hiragana, katakana, and kanji
        $input = "こゝろ、コヽロ、其々";
        $expected = "こころ、ココロ、其其";
        $result = $this->processString($transliterator, $input);
        $this->assertEquals($expected, $result, "Mixed text failed");
        
        // Iteration marks in sentence
        $input = "日々の暮らしはさゝやか";
        $expected = "日日の暮らしはささやか";
        $result = $this->processString($transliterator, $input);
        $this->assertEquals($expected, $result, "Iteration marks in sentence failed");
    }
    
    public function testHalfwidthKatakana(): void
    {
        $transliterator = new JapaneseIterationMarksTransliterator();
        
        // Halfwidth katakana should not be supported
        $input = "ｻヽ";
        $expected = "ｻヽ";
        $result = $this->processString($transliterator, $input);
        $this->assertEquals($expected, $result, "Halfwidth katakana should not be supported");
    }
    
    public function testVoicingEdgeCases(): void
    {
        $transliterator = new JapaneseIterationMarksTransliterator();
        
        // No voicing possible
        $input = "あゞ";
        $expected = "あゞ";
        $result = $this->processString($transliterator, $input);
        $this->assertEquals($expected, $result, "No voicing possible should not change");
        
        // Voicing all consonants
        $input = "かゞたゞはゞさゞ";
        $expected = "かがただはばさざ";
        $result = $this->processString($transliterator, $input);
        $this->assertEquals($expected, $result, "Voicing all consonants failed");
    }
    
    public function testComplexScenarios(): void
    {
        $transliterator = new JapaneseIterationMarksTransliterator();
        
        // Multiple types in sequence
        $input = "思々にこゝろサヾめく";
        $expected = "思思にこころサザめく";
        $result = $this->processString($transliterator, $input);
        $this->assertEquals($expected, $result, "Complex scenario failed");
    }
    
    public function testEmptyString(): void
    {
        $transliterator = new JapaneseIterationMarksTransliterator();
        
        $input = "";
        $expected = "";
        $result = $this->processString($transliterator, $input);
        $this->assertEquals($expected, $result, "Empty string handling failed");
    }
    
    public function testNoIterationMarks(): void
    {
        $transliterator = new JapaneseIterationMarksTransliterator();
        
        $input = "これはテストです";
        $expected = "これはテストです";
        $result = $this->processString($transliterator, $input);
        $this->assertEquals($expected, $result, "No iteration marks should not change");
    }
    
    public function testIterationMarkAfterSpace(): void
    {
        $transliterator = new JapaneseIterationMarksTransliterator();
        
        $input = "さ ゝ";
        $expected = "さ ゝ";
        $result = $this->processString($transliterator, $input);
        $this->assertEquals($expected, $result, "Iteration mark after space should not change");
    }
    
    public function testIterationMarkAfterPunctuation(): void
    {
        $transliterator = new JapaneseIterationMarksTransliterator();
        
        $input = "さ、ゝ";
        $expected = "さ、ゝ";
        $result = $this->processString($transliterator, $input);
        $this->assertEquals($expected, $result, "Iteration mark after punctuation should not change");
    }
    
    public function testIterationMarkAfterASCII(): void
    {
        $transliterator = new JapaneseIterationMarksTransliterator();
        
        $input = "Aゝ";
        $expected = "Aゝ";
        $result = $this->processString($transliterator, $input);
        $this->assertEquals($expected, $result, "Iteration mark after ASCII should not change");
    }
    
    public function testCJKExtensionKanji(): void
    {
        $transliterator = new JapaneseIterationMarksTransliterator();
        
        // CJK Extension A kanji
        $input = "㐀々";
        $expected = "㐀㐀";
        $result = $this->processString($transliterator, $input);
        $this->assertEquals($expected, $result, "CJK Extension A kanji repetition failed");
    }
    
    public function testRegistryIntegration(): void
    {
        // Test that the transliterator can be created via registry
        $factory = TransliteratorRegistry::getTransliteratorFactory('japanese-iteration-marks');
        $transliterator = $factory([]);
        
        $input = "さゝ";
        $expected = "ささ";
        $result = $this->processString($transliterator, $input);
        
        $this->assertEquals($expected, $result, "Registry integration failed");
    }
    
    private function processString(TransliteratorInterface $transliterator, string $input): string
    {
        $chars = Chars::buildCharArray($input);
        return Chars::fromChars($transliterator($chars));
    }
}