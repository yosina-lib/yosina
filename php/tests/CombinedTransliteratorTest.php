<?php

declare(strict_types=1);

namespace Tests;

use PHPUnit\Framework\TestCase;
use Yosina\Chars;
use Yosina\Transliterators\CombinedTransliterator;

class CombinedTransliteratorTest extends TestCase
{
    private CombinedTransliterator $transliterator;

    protected function setUp(): void
    {
        $this->transliterator = new CombinedTransliterator();
    }

    public function testNullSymbolToNul(): void
    {
        $result = Chars::fromChars(($this->transliterator)(Chars::buildCharArray("␀")));
        $this->assertEquals("NUL", $result);
    }

    public function testStartOfHeadingToSoh(): void
    {
        $result = Chars::fromChars(($this->transliterator)(Chars::buildCharArray("␁")));
        $this->assertEquals("SOH", $result);
    }

    public function testStartOfTextToStx(): void
    {
        $result = Chars::fromChars(($this->transliterator)(Chars::buildCharArray("␂")));
        $this->assertEquals("STX", $result);
    }

    public function testBackspaceToBs(): void
    {
        $result = Chars::fromChars(($this->transliterator)(Chars::buildCharArray("␈")));
        $this->assertEquals("BS", $result);
    }

    public function testHorizontalTabToHt(): void
    {
        $result = Chars::fromChars(($this->transliterator)(Chars::buildCharArray("␉")));
        $this->assertEquals("HT", $result);
    }

    public function testCarriageReturnToCr(): void
    {
        $result = Chars::fromChars(($this->transliterator)(Chars::buildCharArray("␍")));
        $this->assertEquals("CR", $result);
    }

    public function testSpaceSymbolToSp(): void
    {
        $result = Chars::fromChars(($this->transliterator)(Chars::buildCharArray("␠")));
        $this->assertEquals("SP", $result);
    }

    public function testDeleteSymbolToDel(): void
    {
        $result = Chars::fromChars(($this->transliterator)(Chars::buildCharArray("␡")));
        $this->assertEquals("DEL", $result);
    }

    public function testParenthesizedNumber1(): void
    {
        $result = Chars::fromChars(($this->transliterator)(Chars::buildCharArray("⑴")));
        $this->assertEquals("(1)", $result);
    }

    public function testParenthesizedNumber5(): void
    {
        $result = Chars::fromChars(($this->transliterator)(Chars::buildCharArray("⑸")));
        $this->assertEquals("(5)", $result);
    }

    public function testParenthesizedNumber10(): void
    {
        $result = Chars::fromChars(($this->transliterator)(Chars::buildCharArray("⑽")));
        $this->assertEquals("(10)", $result);
    }

    public function testParenthesizedNumber20(): void
    {
        $result = Chars::fromChars(($this->transliterator)(Chars::buildCharArray("⒇")));
        $this->assertEquals("(20)", $result);
    }

    public function testPeriodNumber1(): void
    {
        $result = Chars::fromChars(($this->transliterator)(Chars::buildCharArray("⒈")));
        $this->assertEquals("1.", $result);
    }

    public function testPeriodNumber10(): void
    {
        $result = Chars::fromChars(($this->transliterator)(Chars::buildCharArray("⒑")));
        $this->assertEquals("10.", $result);
    }

    public function testPeriodNumber20(): void
    {
        $result = Chars::fromChars(($this->transliterator)(Chars::buildCharArray("⒛")));
        $this->assertEquals("20.", $result);
    }

    public function testParenthesizedLetterA(): void
    {
        $result = Chars::fromChars(($this->transliterator)(Chars::buildCharArray("⒜")));
        $this->assertEquals("(a)", $result);
    }

    public function testParenthesizedLetterZ(): void
    {
        $result = Chars::fromChars(($this->transliterator)(Chars::buildCharArray("⒵")));
        $this->assertEquals("(z)", $result);
    }

    public function testParenthesizedKanjiIchi(): void
    {
        $result = Chars::fromChars(($this->transliterator)(Chars::buildCharArray("㈠")));
        $this->assertEquals("(一)", $result);
    }

    public function testParenthesizedKanjiGetsu(): void
    {
        $result = Chars::fromChars(($this->transliterator)(Chars::buildCharArray("㈪")));
        $this->assertEquals("(月)", $result);
    }

    public function testParenthesizedKanjiKabu(): void
    {
        $result = Chars::fromChars(($this->transliterator)(Chars::buildCharArray("㈱")));
        $this->assertEquals("(株)", $result);
    }

    public function testJapaneseUnitApaato(): void
    {
        $result = Chars::fromChars(($this->transliterator)(Chars::buildCharArray("㌀")));
        $this->assertEquals("アパート", $result);
    }

    public function testJapaneseUnitKiro(): void
    {
        $result = Chars::fromChars(($this->transliterator)(Chars::buildCharArray("㌔")));
        $this->assertEquals("キロ", $result);
    }

    public function testJapaneseUnitMeetoru(): void
    {
        $result = Chars::fromChars(($this->transliterator)(Chars::buildCharArray("㍍")));
        $this->assertEquals("メートル", $result);
    }

    public function testScientificUnitHpa(): void
    {
        $result = Chars::fromChars(($this->transliterator)(Chars::buildCharArray("㍱")));
        $this->assertEquals("hPa", $result);
    }

    public function testScientificUnitKhz(): void
    {
        $result = Chars::fromChars(($this->transliterator)(Chars::buildCharArray("㎑")));
        $this->assertEquals("kHz", $result);
    }

    public function testScientificUnitKg(): void
    {
        $result = Chars::fromChars(($this->transliterator)(Chars::buildCharArray("㎏")));
        $this->assertEquals("kg", $result);
    }

    public function testCombinedControlAndNumbers(): void
    {
        $result = Chars::fromChars(($this->transliterator)(Chars::buildCharArray("␉⑴␠⒈")));
        $this->assertEquals("HT(1)SP1.", $result);
    }

    public function testCombinedWithRegularText(): void
    {
        $result = Chars::fromChars(($this->transliterator)(Chars::buildCharArray("Hello ⑴ World ␉")));
        $this->assertEquals("Hello (1) World HT", $result);
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

    public function testSequenceOfCombinedCharacters(): void
    {
        $inputText = "␀␁␂␃␄";
        $expected = "NULSOHSTXETXEOT";
        $result = Chars::fromChars(($this->transliterator)(Chars::buildCharArray($inputText)));
        $this->assertEquals($expected, $result);
    }

    public function testJapaneseMonths(): void
    {
        $inputText = "㋀㋁㋂";
        $expected = "1月2月3月";
        $result = Chars::fromChars(($this->transliterator)(Chars::buildCharArray($inputText)));
        $this->assertEquals($expected, $result);
    }

    public function testJapaneseUnitsCombinations(): void
    {
        $inputText = "㌀㌁㌂";
        $expected = "アパートアルファアンペア";
        $result = Chars::fromChars(($this->transliterator)(Chars::buildCharArray($inputText)));
        $this->assertEquals($expected, $result);
    }

    public function testScientificMeasurements(): void
    {
        $inputText = "\u{3378}\u{3379}\u{337a}";
        $expected = "dm2dm3IU";
        $result = Chars::fromChars(($this->transliterator)(Chars::buildCharArray($inputText)));
        $this->assertEquals($expected, $result);
    }
}