package com.yosina.icu.tests;

import com.ibm.icu.text.Transliterator;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.io.IOException;

import static org.junit.jupiter.api.Assertions.*;

public class HiraToKataTransliteratorTest extends BaseTransliteratorTest {

    private Transliterator transliterator;

    @BeforeEach
    public void setUp() throws IOException {
        transliterator = createTransliterator("hira_to_kata");
    }

    @Test
    public void testBasicVowels() {
        assertEquals("アイウエオ", transliterate(transliterator, "あいうえお"));
    }

    @Test
    public void testConsonantRows() {
        assertEquals("カキクケコ", transliterate(transliterator, "かきくけこ"));
        assertEquals("サシスセソ", transliterate(transliterator, "さしすせそ"));
        assertEquals("タチツテト", transliterate(transliterator, "たちつてと"));
        assertEquals("ナニヌネノ", transliterate(transliterator, "なにぬねの"));
        assertEquals("ハヒフヘホ", transliterate(transliterator, "はひふへほ"));
        assertEquals("マミムメモ", transliterate(transliterator, "まみむめも"));
        assertEquals("ヤユヨ", transliterate(transliterator, "やゆよ"));
        assertEquals("ラリルレロ", transliterate(transliterator, "らりるれろ"));
        assertEquals("ワヲン", transliterate(transliterator, "わをん"));
    }

    @Test
    public void testVoicedConsonants() {
        assertEquals("ガギグゲゴ", transliterate(transliterator, "がぎぐげご"));
        assertEquals("ザジズゼゾ", transliterate(transliterator, "ざじずぜぞ"));
        assertEquals("ダヂヅデド", transliterate(transliterator, "だぢづでど"));
        assertEquals("バビブベボ", transliterate(transliterator, "ばびぶべぼ"));
    }

    @Test
    public void testSemiVoiced() {
        assertEquals("パピプペポ", transliterate(transliterator, "ぱぴぷぺぽ"));
    }

    @Test
    public void testSmallKana() {
        assertEquals("ァィゥェォ", transliterate(transliterator, "ぁぃぅぇぉ"));
        assertEquals("ッャュョ", transliterate(transliterator, "っゃゅょ"));
        assertEquals("ヮ", transliterate(transliterator, "ゎ"));
    }

    @Test
    public void testIterationMarks() {
        assertEquals("ヽ", transliterate(transliterator, "ゝ"));
        assertEquals("ヾ", transliterate(transliterator, "ゞ"));
    }

    @Test
    public void testSentence() {
        String input = "こんにちは　せかい";
        String expected = "コンニチハ　セカイ";
        assertEquals(expected, transliterate(transliterator, input));
    }

    @Test
    public void testKatakanaUnchanged() {
        String input = "カタカナ";
        assertEquals(input, transliterate(transliterator, input));
    }

    @Test
    public void testMixedScript() {
        String input = "hello ひらがな 123";
        assertEquals("hello ヒラガナ 123", transliterate(transliterator, input));
    }

    @Test
    public void testEmptyString() {
        assertEquals("", transliterate(transliterator, ""));
    }
}
