package com.yosina.icu.tests;

import com.ibm.icu.text.Transliterator;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.io.IOException;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Tests for Japanese Iteration Marks transliterator ICU rules.
 */
public class JapaneseIterationMarksTransliteratorTest extends BaseTransliteratorTest {
    
    private Transliterator transliterator;
    
    @BeforeEach
    public void setUp() throws IOException {
        transliterator = createTransliterator("japanese_iteration_marks");
    }
    
    @Test
    public void testHiraganaIterationMark() {
        assertEquals("ここ", transliterate(transliterator, "こゝ"));
        assertEquals("たた", transliterate(transliterator, "たゝ"));
        assertEquals("しし", transliterate(transliterator, "しゝ"));
    }
    
    @Test
    public void testHiraganaVoicedIterationMark() {
        assertEquals("かが", transliterate(transliterator, "かゞ"));
        assertEquals("きぎ", transliterate(transliterator, "きゞ"));
        assertEquals("くぐ", transliterate(transliterator, "くゞ"));
        assertEquals("けげ", transliterate(transliterator, "けゞ"));
        assertEquals("こご", transliterate(transliterator, "こゞ"));
        
        assertEquals("さざ", transliterate(transliterator, "さゞ"));
        assertEquals("しじ", transliterate(transliterator, "しゞ"));
        assertEquals("すず", transliterate(transliterator, "すゞ"));
        assertEquals("せぜ", transliterate(transliterator, "せゞ"));
        assertEquals("そぞ", transliterate(transliterator, "そゞ"));
        
        assertEquals("ただ", transliterate(transliterator, "たゞ"));
        assertEquals("ちぢ", transliterate(transliterator, "ちゞ"));
        assertEquals("つづ", transliterate(transliterator, "つゞ"));
        assertEquals("てで", transliterate(transliterator, "てゞ"));
        assertEquals("とど", transliterate(transliterator, "とゞ"));
        
        assertEquals("はば", transliterate(transliterator, "はゞ"));
        assertEquals("ひび", transliterate(transliterator, "ひゞ"));
        assertEquals("ふぶ", transliterate(transliterator, "ふゞ"));
        assertEquals("へべ", transliterate(transliterator, "へゞ"));
        assertEquals("ほぼ", transliterate(transliterator, "ほゞ"));
    }
    
    @Test
    public void testHiraganaVoicedIterationMarkAfterVoicedChar() {
        // Voiced iteration mark after already-voiced character repeats the voiced char
        assertEquals("がが", transliterate(transliterator, "がゞ"));
        assertEquals("ぎぎ", transliterate(transliterator, "ぎゞ"));
        assertEquals("ざざ", transliterate(transliterator, "ざゞ"));
        assertEquals("だだ", transliterate(transliterator, "だゞ"));
        assertEquals("ばば", transliterate(transliterator, "ばゞ"));
    }

    @Test
    public void testHiraganaUnvoicedIterationMarkAfterVoicedChar() {
        // Unvoiced iteration mark after voiced character yields unvoiced version
        assertEquals("がか", transliterate(transliterator, "がゝ"));
        assertEquals("ぎき", transliterate(transliterator, "ぎゝ"));
        assertEquals("ざさ", transliterate(transliterator, "ざゝ"));
        assertEquals("だた", transliterate(transliterator, "だゝ"));
        assertEquals("ばは", transliterate(transliterator, "ばゝ"));
    }

    @Test
    public void testKatakanaIterationMark() {
        assertEquals("ココ", transliterate(transliterator, "コヽ"));
        assertEquals("タタ", transliterate(transliterator, "タヽ"));
        assertEquals("シシ", transliterate(transliterator, "シヽ"));
    }
    
    @Test
    public void testKatakanaVoicedIterationMark() {
        assertEquals("カガ", transliterate(transliterator, "カヾ"));
        assertEquals("キギ", transliterate(transliterator, "キヾ"));
        assertEquals("クグ", transliterate(transliterator, "クヾ"));
        assertEquals("ケゲ", transliterate(transliterator, "ケヾ"));
        assertEquals("コゴ", transliterate(transliterator, "コヾ"));
        
        assertEquals("サザ", transliterate(transliterator, "サヾ"));
        assertEquals("シジ", transliterate(transliterator, "シヾ"));
        assertEquals("スズ", transliterate(transliterator, "スヾ"));
        assertEquals("セゼ", transliterate(transliterator, "セヾ"));
        assertEquals("ソゾ", transliterate(transliterator, "ソヾ"));
        
        assertEquals("タダ", transliterate(transliterator, "タヾ"));
        assertEquals("チヂ", transliterate(transliterator, "チヾ"));
        assertEquals("ツヅ", transliterate(transliterator, "ツヾ"));
        assertEquals("テデ", transliterate(transliterator, "テヾ"));
        assertEquals("トド", transliterate(transliterator, "トヾ"));
        
        assertEquals("ハバ", transliterate(transliterator, "ハヾ"));
        assertEquals("ヒビ", transliterate(transliterator, "ヒヾ"));
        assertEquals("フブ", transliterate(transliterator, "フヾ"));
        assertEquals("ヘベ", transliterate(transliterator, "ヘヾ"));
        assertEquals("ホボ", transliterate(transliterator, "ホヾ"));
        
        assertEquals("ウヴ", transliterate(transliterator, "ウヾ"));
    }
    
    @Test
    public void testKatakanaVoicedIterationMarkAfterVoicedChar() {
        // Voiced iteration mark after already-voiced character repeats the voiced char
        assertEquals("ガガ", transliterate(transliterator, "ガヾ"));
        assertEquals("ギギ", transliterate(transliterator, "ギヾ"));
        assertEquals("ザザ", transliterate(transliterator, "ザヾ"));
        assertEquals("ダダ", transliterate(transliterator, "ダヾ"));
        assertEquals("ババ", transliterate(transliterator, "バヾ"));
    }

    @Test
    public void testKatakanaUnvoicedIterationMarkAfterVoicedChar() {
        // Unvoiced iteration mark after voiced character yields unvoiced version
        assertEquals("ガカ", transliterate(transliterator, "ガヽ"));
        assertEquals("ギキ", transliterate(transliterator, "ギヽ"));
        assertEquals("ザサ", transliterate(transliterator, "ザヽ"));
        assertEquals("ダタ", transliterate(transliterator, "ダヽ"));
        assertEquals("バハ", transliterate(transliterator, "バヽ"));
    }

    @Test
    public void testKanjiIterationMark() {
        assertEquals("人人", transliterate(transliterator, "人々"));
        assertEquals("日日", transliterate(transliterator, "日々"));
        assertEquals("年年", transliterate(transliterator, "年々"));
        assertEquals("様様", transliterate(transliterator, "様々"));
        assertEquals("時時", transliterate(transliterator, "時々"));
    }
    
    @Test
    public void testMixedIterationMarks() {
        String input = "ここゝろ、ココヽロ、心々";
        String expected = "ここころ、コココロ、心心";
        assertEquals(expected, transliterate(transliterator, input));
    }
    
    @Test
    public void testIterationMarksInSentence() {
        String input = "日々の生活でさまゝまな出来事";
        String expected = "日日の生活でさまままな出来事";
        assertEquals(expected, transliterate(transliterator, input));
    }
    
    @Test
    public void testInvalidIterationMark() {
        // Iteration mark without valid preceding character
        assertEquals("ゝ", transliterate(transliterator, "ゝ"));
        assertEquals("ゞ", transliterate(transliterator, "ゞ"));
        assertEquals("ヽ", transliterate(transliterator, "ヽ"));
        assertEquals("ヾ", transliterate(transliterator, "ヾ"));
        assertEquals("々", transliterate(transliterator, "々"));
    }
    
    @Test
    public void testIterationMarkAfterNonJapanese() {
        // Iteration marks after non-Japanese characters should not be replaced
        assertEquals("Aゝ", transliterate(transliterator, "Aゝ"));
        assertEquals("1々", transliterate(transliterator, "1々"));
        assertEquals(" ヽ", transliterate(transliterator, " ヽ"));
    }
    
    @Test
    public void testEmptyString() {
        assertEquals("", transliterate(transliterator, ""));
    }
    
    @Test
    public void testNoIterationMarks() {
        String input = "これはテストです";
        assertEquals(input, transliterate(transliterator, input));
    }
}