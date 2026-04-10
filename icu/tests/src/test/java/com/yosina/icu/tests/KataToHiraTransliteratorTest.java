package com.yosina.icu.tests;

import com.ibm.icu.text.Transliterator;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.io.IOException;

import static org.junit.jupiter.api.Assertions.*;

public class KataToHiraTransliteratorTest extends BaseTransliteratorTest {

    private Transliterator transliterator;

    @BeforeEach
    public void setUp() throws IOException {
        transliterator = createTransliterator("kata_to_hira");
    }

    @Test
    public void testBasicVowels() {
        assertEquals("あいうえお", transliterate(transliterator, "アイウエオ"));
    }

    @Test
    public void testConsonantRows() {
        assertEquals("かきくけこ", transliterate(transliterator, "カキクケコ"));
        assertEquals("さしすせそ", transliterate(transliterator, "サシスセソ"));
        assertEquals("たちつてと", transliterate(transliterator, "タチツテト"));
        assertEquals("なにぬねの", transliterate(transliterator, "ナニヌネノ"));
        assertEquals("はひふへほ", transliterate(transliterator, "ハヒフヘホ"));
        assertEquals("まみむめも", transliterate(transliterator, "マミムメモ"));
        assertEquals("やゆよ", transliterate(transliterator, "ヤユヨ"));
        assertEquals("らりるれろ", transliterate(transliterator, "ラリルレロ"));
        assertEquals("わをん", transliterate(transliterator, "ワヲン"));
    }

    @Test
    public void testVoicedConsonants() {
        assertEquals("がぎぐげご", transliterate(transliterator, "ガギグゲゴ"));
        assertEquals("ざじずぜぞ", transliterate(transliterator, "ザジズゼゾ"));
        assertEquals("だぢづでど", transliterate(transliterator, "ダヂヅデド"));
        assertEquals("ばびぶべぼ", transliterate(transliterator, "バビブベボ"));
    }

    @Test
    public void testSemiVoiced() {
        assertEquals("ぱぴぷぺぽ", transliterate(transliterator, "パピプペポ"));
    }

    @Test
    public void testSmallKana() {
        assertEquals("ぁぃぅぇぉ", transliterate(transliterator, "ァィゥェォ"));
        assertEquals("っゃゅょ", transliterate(transliterator, "ッャュョ"));
        assertEquals("ゎ", transliterate(transliterator, "ヮ"));
    }

    @Test
    public void testIterationMarks() {
        assertEquals("ゝ", transliterate(transliterator, "ヽ"));
        assertEquals("ゞ", transliterate(transliterator, "ヾ"));
    }

    @Test
    public void testSentence() {
        assertEquals("こんにちは", transliterate(transliterator, "コンニチハ"));
    }

    @Test
    public void testHiraganaUnchanged() {
        String input = "ひらがな";
        assertEquals(input, transliterate(transliterator, input));
    }

    @Test
    public void testEmptyString() {
        assertEquals("", transliterate(transliterator, ""));
    }
}
