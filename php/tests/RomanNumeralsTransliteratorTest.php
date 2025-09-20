<?php

declare(strict_types=1);

use PHPUnit\Framework\Attributes\DataProvider;
use PHPUnit\Framework\TestCase;
use Yosina\Chars;
use Yosina\Transliterators\RomanNumeralsTransliterator;

class RomanNumeralsTransliteratorTest extends TestCase
{
    /**
     * @return array<array{0:string,1:string,2:string}>
     */
    public static function uppercaseRomanNumeralsProvider(): array
    {
        return [
            ["I", "Ⅰ", "Roman I"],
            ["II", "Ⅱ", "Roman II"],
            ["III", "Ⅲ", "Roman III"],
            ["IV", "Ⅳ", "Roman IV"],
            ["V", "Ⅴ", "Roman V"],
            ["VI", "Ⅵ", "Roman VI"],
            ["VII", "Ⅶ", "Roman VII"],
            ["VIII", "Ⅷ", "Roman VIII"],
            ["IX", "Ⅸ", "Roman IX"],
            ["X", "Ⅹ", "Roman X"],
            ["XI", "Ⅺ", "Roman XI"],
            ["XII", "Ⅻ", "Roman XII"],
            ["L", "Ⅼ", "Roman L"],
            ["C", "Ⅽ", "Roman C"],
            ["D", "Ⅾ", "Roman D"],
            ["M", "Ⅿ", "Roman M"],
        ];
    }

    #[DataProvider('uppercaseRomanNumeralsProvider')]
    public function testUppercaseRomanNumerals(string $expected, string $input, string $description): void
    {
        $transliterator = new RomanNumeralsTransliterator();
        $chars = Chars::buildCharArray($input);
        $result = $transliterator($chars);
        $this->assertEquals($expected, Chars::fromChars($result), $description);
    }

    /**
     * @return array<array{0:string,1:string,2:string}>
     */
    public static function lowercaseRomanNumeralsProvider(): array
    {
        return [
            ["i", "ⅰ", "Roman i"],
            ["ii", "ⅱ", "Roman ii"],
            ["iii", "ⅲ", "Roman iii"],
            ["iv", "ⅳ", "Roman iv"],
            ["v", "ⅴ", "Roman v"],
            ["vi", "ⅵ", "Roman vi"],
            ["vii", "ⅶ", "Roman vii"],
            ["viii", "ⅷ", "Roman viii"],
            ["ix", "ⅸ", "Roman ix"],
            ["x", "ⅹ", "Roman x"],
            ["xi", "ⅺ", "Roman xi"],
            ["xii", "ⅻ", "Roman xii"],
            ["l", "ⅼ", "Roman l"],
            ["c", "ⅽ", "Roman c"],
            ["d", "ⅾ", "Roman d"],
            ["m", "ⅿ", "Roman m"],
        ];
    }

    #[DataProvider('lowercaseRomanNumeralsProvider')]
    public function testLowercaseRomanNumerals(string $expected, string $input, string $description): void
    {
        $transliterator = new RomanNumeralsTransliterator();
        $chars = Chars::buildCharArray($input);
        $result = $transliterator($chars);
        $this->assertEquals($expected, Chars::fromChars($result), $description);
    }

    /**
     * @return array<array{0:string,1:string,2:string}>
     */
    public static function mixedTextProvider(): array
    {
        return [
            ["Year XII", "Year Ⅻ", "Year with Roman numeral"],
            ["Chapter iv", "Chapter ⅳ", "Chapter with lowercase Roman"],
            ["Section III.A", "Section Ⅲ.A", "Section with Roman and period"],
            ["I II III", "Ⅰ Ⅱ Ⅲ", "Multiple uppercase Romans"],
            ["i, ii, iii", "ⅰ, ⅱ, ⅲ", "Multiple lowercase Romans"],
        ];
    }

    #[DataProvider('mixedTextProvider')]
    public function testMixedText(string $expected, string $input, string $description): void
    {
        $transliterator = new RomanNumeralsTransliterator();
        $chars = Chars::buildCharArray($input);
        $result = $transliterator($chars);
        $this->assertEquals($expected, Chars::fromChars($result), $description);
    }

    /**
     * @return array<array{0:string,1:string,2:string}>
     */
    public static function edgeCasesProvider(): array
    {
        return [
            ["", "", "Empty string"],
            ["ABC123", "ABC123", "No Roman numerals"],
            ["IIIIII", "ⅠⅡⅢ", "Consecutive Romans"],
        ];
    }

    #[DataProvider('edgeCasesProvider')]
    public function testEdgeCases(string $expected, string $input, string $description): void
    {
        $transliterator = new RomanNumeralsTransliterator();
        $chars = Chars::buildCharArray($input);
        $result = $transliterator($chars);
        $this->assertEquals($expected, Chars::fromChars($result), $description);
    }
}