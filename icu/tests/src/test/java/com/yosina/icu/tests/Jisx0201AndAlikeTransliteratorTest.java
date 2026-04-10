package com.yosina.icu.tests;

import com.ibm.icu.text.Transliterator;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.io.IOException;

import static org.junit.jupiter.api.Assertions.*;

public class Jisx0201AndAlikeTransliteratorTest extends BaseTransliteratorTest {

    private Transliterator transliterator;

    @BeforeEach
    public void setUp() throws IOException {
        transliterator = createTransliterator("jisx0201_and_alike");
    }

    @Test
    public void testFullwidthAlphaToHalfwidth() {
        assertEquals("ABC", transliterate(transliterator, "\uFF21\uFF22\uFF23"));
        assertEquals("abc", transliterate(transliterator, "\uFF41\uFF42\uFF43"));
        assertEquals("XYZ", transliterate(transliterator, "\uFF38\uFF39\uFF3A"));
    }

    @Test
    public void testFullwidthDigitsToHalfwidth() {
        assertEquals("0123456789", transliterate(transliterator,
                "\uFF10\uFF11\uFF12\uFF13\uFF14\uFF15\uFF16\uFF17\uFF18\uFF19"));
    }

    @Test
    public void testFullwidthPunctuation() {
        assertEquals("!", transliterate(transliterator, "\uFF01"));
        assertEquals("?", transliterate(transliterator, "\uFF1F"));
        assertEquals("(", transliterate(transliterator, "\uFF08"));
        assertEquals(")", transliterate(transliterator, "\uFF09"));
        assertEquals(",", transliterate(transliterator, "\uFF0C"));
        assertEquals(".", transliterate(transliterator, "\uFF0E"));
    }

    @Test
    public void testIdeographicSpace() {
        assertEquals(" ", transliterate(transliterator, "\u3000"));
    }

    @Test
    public void testKatakanaToHalfwidth() {
        assertEquals("\uFF71", transliterate(transliterator, "\u30A2")); // ア → ｱ
        assertEquals("\uFF72", transliterate(transliterator, "\u30A4")); // イ → ｲ
        assertEquals("\uFF73", transliterate(transliterator, "\u30A6")); // ウ → ｳ
        assertEquals("\uFF74", transliterate(transliterator, "\u30A8")); // エ → ｴ
        assertEquals("\uFF75", transliterate(transliterator, "\u30AA")); // オ → ｵ
    }

    @Test
    public void testVoicedKatakanaToHalfwidthWithDakuten() {
        // ガ → ｶﾞ (base + dakuten mark)
        assertEquals("\uFF76\uFF9E", transliterate(transliterator, "\u30AC"));
        // ザ → ｻﾞ
        assertEquals("\uFF7B\uFF9E", transliterate(transliterator, "\u30B6"));
        // ダ → ﾀﾞ
        assertEquals("\uFF80\uFF9E", transliterate(transliterator, "\u30C0"));
        // バ → ﾊﾞ
        assertEquals("\uFF8A\uFF9E", transliterate(transliterator, "\u30D0"));
    }

    @Test
    public void testSemiVoicedKatakanaToHalfwidth() {
        // パ → ﾊﾟ (base + handakuten mark)
        assertEquals("\uFF8A\uFF9F", transliterate(transliterator, "\u30D1"));
        // ピ → ﾋﾟ
        assertEquals("\uFF8B\uFF9F", transliterate(transliterator, "\u30D4"));
        // プ → ﾌﾟ
        assertEquals("\uFF8C\uFF9F", transliterate(transliterator, "\u30D7"));
    }

    @Test
    public void testKatakanaPunctuation() {
        assertEquals("\uFF61", transliterate(transliterator, "\u3002")); // 。→ ｡
        assertEquals("\uFF62", transliterate(transliterator, "\u300C")); // 「→ ｢
        assertEquals("\uFF63", transliterate(transliterator, "\u300D")); // 」→ ｣
        assertEquals("\uFF64", transliterate(transliterator, "\u3001")); // 、→ ､
        assertEquals("\uFF65", transliterate(transliterator, "\u30FB")); // ・→ ･
    }

    @Test
    public void testProlongedSoundMark() {
        assertEquals("\uFF70", transliterate(transliterator, "\u30FC")); // ー → ｰ
    }

    @Test
    public void testSmallKatakana() {
        assertEquals("\uFF67", transliterate(transliterator, "\u30A1")); // ァ → ｧ
        assertEquals("\uFF6F", transliterate(transliterator, "\u30C3")); // ッ → ｯ
        assertEquals("\uFF6C", transliterate(transliterator, "\u30E3")); // ャ → ｬ
    }

    @Test
    public void testMixedText() {
        String input = "\uFF21\uFF22\uFF23\u3000\u30AB\u30BF\u30AB\u30CA";
        // ＡＢＣ　カタカナ → ABC ｶﾀｶﾅ
        assertEquals("ABC \uFF76\uFF80\uFF76\uFF85", transliterate(transliterator, input));
    }

    @Test
    public void testHalfwidthUnchanged() {
        String input = "ABC 123";
        assertEquals(input, transliterate(transliterator, input));
    }

    @Test
    public void testHiraganaUnchanged() {
        // Default: convert_hiraganas=False
        String input = "ひらがな";
        assertEquals(input, transliterate(transliterator, input));
    }

    @Test
    public void testEmptyString() {
        assertEquals("", transliterate(transliterator, ""));
    }
}
