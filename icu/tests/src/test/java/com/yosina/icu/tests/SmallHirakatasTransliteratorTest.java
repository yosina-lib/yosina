package com.yosina.icu.tests;

import com.ibm.icu.text.Transliterator;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.io.IOException;

import static org.junit.jupiter.api.Assertions.*;

public class SmallHirakatasTransliteratorTest extends BaseTransliteratorTest {

    private Transliterator transliterator;

    @BeforeEach
    public void setUp() throws IOException {
        transliterator = createTransliterator("small_hirakatas");
    }

    @Test
    public void testSmallHiraganaVowels() {
        assertEquals("あ", transliterate(transliterator, "ぁ"));
        assertEquals("い", transliterate(transliterator, "ぃ"));
        assertEquals("う", transliterate(transliterator, "ぅ"));
        assertEquals("え", transliterate(transliterator, "ぇ"));
        assertEquals("お", transliterate(transliterator, "ぉ"));
    }

    @Test
    public void testSmallKatakanaVowels() {
        assertEquals("ア", transliterate(transliterator, "ァ"));
        assertEquals("イ", transliterate(transliterator, "ィ"));
        assertEquals("ウ", transliterate(transliterator, "ゥ"));
        assertEquals("エ", transliterate(transliterator, "ェ"));
        assertEquals("オ", transliterate(transliterator, "ォ"));
    }

    @Test
    public void testSmallTsuAndYaYuYo() {
        assertEquals("つ", transliterate(transliterator, "っ"));
        assertEquals("や", transliterate(transliterator, "ゃ"));
        assertEquals("ゆ", transliterate(transliterator, "ゅ"));
        assertEquals("よ", transliterate(transliterator, "ょ"));
    }

    @Test
    public void testSmallKatakanaConsonants() {
        assertEquals("ツ", transliterate(transliterator, "ッ"));
        assertEquals("ヤ", transliterate(transliterator, "ャ"));
        assertEquals("ユ", transliterate(transliterator, "ュ"));
        assertEquals("ヨ", transliterate(transliterator, "ョ"));
    }

    @Test
    public void testSmallWa() {
        assertEquals("わ", transliterate(transliterator, "ゎ"));
        assertEquals("ワ", transliterate(transliterator, "ヮ"));
    }

    @Test
    public void testSmallKaKe() {
        assertEquals("か", transliterate(transliterator, "ゕ"));
        assertEquals("け", transliterate(transliterator, "ゖ"));
        assertEquals("カ", transliterate(transliterator, "ヵ"));
        assertEquals("ケ", transliterate(transliterator, "ヶ"));
    }

    @Test
    public void testHalfwidthSmallKatakana() {
        assertEquals("ｱ", transliterate(transliterator, "ｧ"));
        assertEquals("ｲ", transliterate(transliterator, "ｨ"));
        assertEquals("ｳ", transliterate(transliterator, "ｩ"));
        assertEquals("ｴ", transliterate(transliterator, "ｪ"));
        assertEquals("ｵ", transliterate(transliterator, "ｫ"));
        assertEquals("ﾂ", transliterate(transliterator, "ｯ"));
        assertEquals("ﾔ", transliterate(transliterator, "ｬ"));
        assertEquals("ﾕ", transliterate(transliterator, "ｭ"));
        assertEquals("ﾖ", transliterate(transliterator, "ｮ"));
    }

    @Test
    public void testMixedText() {
        String input = "ファイル";
        // ァ → ア, rest unchanged
        assertEquals("フアイル", transliterate(transliterator, input));
    }

    @Test
    public void testNormalSizeUnchanged() {
        String input = "あいうえお";
        assertEquals(input, transliterate(transliterator, input));
    }

    @Test
    public void testEmptyString() {
        assertEquals("", transliterate(transliterator, ""));
    }
}
