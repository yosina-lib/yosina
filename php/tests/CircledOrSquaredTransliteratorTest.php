<?php

declare(strict_types=1);

namespace Tests;

use PHPUnit\Framework\TestCase;
use Yosina\Chars;
use Yosina\Transliterators\CircledOrSquaredTransliterator;

class CircledOrSquaredTransliteratorTest extends TestCase
{
    private CircledOrSquaredTransliterator $transliterator;

    protected function setUp(): void
    {
        $this->transliterator = new CircledOrSquaredTransliterator();
    }

    public function testCircledNumber1(): void
    {
        $result = Chars::fromChars(($this->transliterator)(Chars::buildCharArray("①")));
        $this->assertEquals("(1)", $result);
    }

    public function testCircledNumber2(): void
    {
        $result = Chars::fromChars(($this->transliterator)(Chars::buildCharArray("②")));
        $this->assertEquals("(2)", $result);
    }

    public function testCircledNumber20(): void
    {
        $result = Chars::fromChars(($this->transliterator)(Chars::buildCharArray("⑳")));
        $this->assertEquals("(20)", $result);
    }

    public function testCircledNumber0(): void
    {
        $result = Chars::fromChars(($this->transliterator)(Chars::buildCharArray("⓪")));
        $this->assertEquals("(0)", $result);
    }

    public function testCircledUppercaseA(): void
    {
        $result = Chars::fromChars(($this->transliterator)(Chars::buildCharArray("Ⓐ")));
        $this->assertEquals("(A)", $result);
    }

    public function testCircledUppercaseZ(): void
    {
        $result = Chars::fromChars(($this->transliterator)(Chars::buildCharArray("Ⓩ")));
        $this->assertEquals("(Z)", $result);
    }

    public function testCircledLowercaseA(): void
    {
        $result = Chars::fromChars(($this->transliterator)(Chars::buildCharArray("ⓐ")));
        $this->assertEquals("(a)", $result);
    }

    public function testCircledLowercaseZ(): void
    {
        $result = Chars::fromChars(($this->transliterator)(Chars::buildCharArray("ⓩ")));
        $this->assertEquals("(z)", $result);
    }

    public function testCircledKanjiIchi(): void
    {
        $result = Chars::fromChars(($this->transliterator)(Chars::buildCharArray("㊀")));
        $this->assertEquals("(一)", $result);
    }

    public function testCircledKanjiGetsu(): void
    {
        $result = Chars::fromChars(($this->transliterator)(Chars::buildCharArray("㊊")));
        $this->assertEquals("(月)", $result);
    }

    public function testCircledKanjiYoru(): void
    {
        $result = Chars::fromChars(($this->transliterator)(Chars::buildCharArray("㊰")));
        $this->assertEquals("(夜)", $result);
    }

    public function testCircledKatakanaA(): void
    {
        $result = Chars::fromChars(($this->transliterator)(Chars::buildCharArray("㋐")));
        $this->assertEquals("(ア)", $result);
    }

    public function testCircledKatakanaWo(): void
    {
        $result = Chars::fromChars(($this->transliterator)(Chars::buildCharArray("㋾")));
        $this->assertEquals("(ヲ)", $result);
    }

    public function testSquaredLetterA(): void
    {
        $result = Chars::fromChars(($this->transliterator)(Chars::buildCharArray("🅰")));
        $this->assertEquals("[A]", $result);
    }

    public function testSquaredLetterZ(): void
    {
        $result = Chars::fromChars(($this->transliterator)(Chars::buildCharArray("🆉")));
        $this->assertEquals("[Z]", $result);
    }

    public function testRegionalIndicatorA(): void
    {
        $result = Chars::fromChars(($this->transliterator)(Chars::buildCharArray("🇦")));
        $this->assertEquals("[A]", $result);
    }

    public function testRegionalIndicatorZ(): void
    {
        $result = Chars::fromChars(($this->transliterator)(Chars::buildCharArray("🇿")));
        $this->assertEquals("[Z]", $result);
    }

    public function testEmojiExclusionDefault(): void
    {
        $result = Chars::fromChars(($this->transliterator)(Chars::buildCharArray("🆂🅾🆂")));
        $this->assertEquals("[S][O][S]", $result);
    }

    public function testEmptyString(): void
    {
        $result = Chars::fromChars(($this->transliterator)(Chars::buildCharArray("")));
        $this->assertEquals("", $result);
    }

    public function testUnmappedCharacters(): void
    {
        $inputText = "hello world 123 abc こんにちは";
        $result = Chars::fromChars(($this->transliterator)(Chars::buildCharArray($inputText)));
        $this->assertEquals($inputText, $result);
    }

    public function testMixedContent(): void
    {
        $inputText = "Hello ① World Ⓐ Test";
        $expected = "Hello (1) World (A) Test";
        $result = Chars::fromChars(($this->transliterator)(Chars::buildCharArray($inputText)));
        $this->assertEquals($expected, $result);
    }

    public function testSequenceOfCircledNumbers(): void
    {
        $inputText = "①②③④⑤";
        $expected = "(1)(2)(3)(4)(5)";
        $result = Chars::fromChars(($this->transliterator)(Chars::buildCharArray($inputText)));
        $this->assertEquals($expected, $result);
    }

    public function testSequenceOfCircledLetters(): void
    {
        $inputText = "ⒶⒷⒸ";
        $expected = "(A)(B)(C)";
        $result = Chars::fromChars(($this->transliterator)(Chars::buildCharArray($inputText)));
        $this->assertEquals($expected, $result);
    }

    public function testMixedCirclesAndSquares(): void
    {
        $inputText = "①🅰②🅱";
        $expected = "(1)[A](2)[B]";
        $result = Chars::fromChars(($this->transliterator)(Chars::buildCharArray($inputText)));
        $this->assertEquals($expected, $result);
    }

    public function testCircledKanjiSequence(): void
    {
        $inputText = "㊀㊁㊂㊃㊄";
        $expected = "(一)(二)(三)(四)(五)";
        $result = Chars::fromChars(($this->transliterator)(Chars::buildCharArray($inputText)));
        $this->assertEquals($expected, $result);
    }

    public function testJapaneseTextWithCircledElements(): void
    {
        $inputText = "項目①は重要で、項目②は補足です。";
        $expected = "項目(1)は重要で、項目(2)は補足です。";
        $result = Chars::fromChars(($this->transliterator)(Chars::buildCharArray($inputText)));
        $this->assertEquals($expected, $result);
    }

    public function testNumberedListWithCircledNumbers(): void
    {
        $inputText = "①準備\n②実行\n③確認";
        $expected = "(1)準備\n(2)実行\n(3)確認";
        $result = Chars::fromChars(($this->transliterator)(Chars::buildCharArray($inputText)));
        $this->assertEquals($expected, $result);
    }

    public function testLargeCircledNumbers(): void
    {
        $inputText = "㊱㊲㊳";
        $expected = "(36)(37)(38)";
        $result = Chars::fromChars(($this->transliterator)(Chars::buildCharArray($inputText)));
        $this->assertEquals($expected, $result);
    }

    public function testCircledNumbersUpTo50(): void
    {
        $inputText = "㊿";
        $expected = "(50)";
        $result = Chars::fromChars(($this->transliterator)(Chars::buildCharArray($inputText)));
        $this->assertEquals($expected, $result);
    }

    public function testSpecialCircledCharacters(): void
    {
        $inputText = "🄴🅂";
        $expected = "[E][S]";
        $result = Chars::fromChars(($this->transliterator)(Chars::buildCharArray($inputText)));
        $this->assertEquals($expected, $result);
    }
}

class CircledOrSquaredTransliteratorIncludeEmojisTest extends TestCase
{
    public function testIncludeEmojisTrue(): void
    {
        $transliterator = new CircledOrSquaredTransliterator(['includeEmojis' => true]);
        $result = Chars::fromChars(($transliterator)(Chars::buildCharArray("🆘")));
        $this->assertEquals("[SOS]", $result);
    }

    public function testIncludeEmojisFalse(): void
    {
        $transliterator = new CircledOrSquaredTransliterator(['includeEmojis' => false]);
        $result = Chars::fromChars(($transliterator)(Chars::buildCharArray("🆘")));
        $this->assertEquals("🆘", $result);
    }
}

class CircledOrSquaredTransliteratorCustomTemplatesTest extends TestCase
{
    private CircledOrSquaredTransliterator $transliterator;

    protected function setUp(): void
    {
        $this->transliterator = new CircledOrSquaredTransliterator([
            'templates' => [
                'circle' => '〔?〕',
                'square' => '【?】'
            ]
        ]);
    }

    public function testCustomCircleTemplate(): void
    {
        $result = Chars::fromChars(($this->transliterator)(Chars::buildCharArray("①")));
        $this->assertEquals("〔1〕", $result);
    }

    public function testCustomSquareTemplate(): void
    {
        $result = Chars::fromChars(($this->transliterator)(Chars::buildCharArray("🅰")));
        $this->assertEquals("【A】", $result);
    }

    public function testCustomTemplatesWithKanji(): void
    {
        $result = Chars::fromChars(($this->transliterator)(Chars::buildCharArray("㊀")));
        $this->assertEquals("〔一〕", $result);
    }
}