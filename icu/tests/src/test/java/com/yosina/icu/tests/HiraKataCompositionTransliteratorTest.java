package com.yosina.icu.tests;

import com.ibm.icu.text.Transliterator;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.io.IOException;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Tests for Hiragana-Katakana Composition transliterator ICU rules.
 *
 * The ICU rules handle non-combining marks (゛ U+309B, ゜ U+309C).
 * Combining marks (U+3099, U+309A) are handled by ICU's built-in NFC normalization.
 */
public class HiraKataCompositionTransliteratorTest extends BaseTransliteratorTest {

    private Transliterator transliterator;
    private Transliterator transliteratorWithNfc;

    @BeforeEach
    public void setUp() throws IOException {
        transliterator = createTransliterator("hira_kata_composition");
        // Chain with NFC to also handle combining marks
        String rules = loadRules("hira_kata_composition");
        transliteratorWithNfc = Transliterator.createFromRules(
            "hira_kata_composition_nfc",
            rules + "\n::NFC;",
            Transliterator.FORWARD
        );
    }

    // --- Non-combining mark tests (゛ U+309B, ゜ U+309C) ---
    // These are the primary purpose of this transliterator.

    @Test
    public void testHiraganaWithNonCombiningVoicedMark() {
        assertEquals("が", transliterate(transliterator, "か\u309B"));
        assertEquals("ぎ", transliterate(transliterator, "き\u309B"));
        assertEquals("ぐ", transliterate(transliterator, "く\u309B"));
        assertEquals("げ", transliterate(transliterator, "け\u309B"));
        assertEquals("ご", transliterate(transliterator, "こ\u309B"));

        assertEquals("ざ", transliterate(transliterator, "さ\u309B"));
        assertEquals("じ", transliterate(transliterator, "し\u309B"));
        assertEquals("ず", transliterate(transliterator, "す\u309B"));
        assertEquals("ぜ", transliterate(transliterator, "せ\u309B"));
        assertEquals("ぞ", transliterate(transliterator, "そ\u309B"));

        assertEquals("だ", transliterate(transliterator, "た\u309B"));
        assertEquals("ぢ", transliterate(transliterator, "ち\u309B"));
        assertEquals("づ", transliterate(transliterator, "つ\u309B"));
        assertEquals("で", transliterate(transliterator, "て\u309B"));
        assertEquals("ど", transliterate(transliterator, "と\u309B"));

        assertEquals("ば", transliterate(transliterator, "は\u309B"));
        assertEquals("び", transliterate(transliterator, "ひ\u309B"));
        assertEquals("ぶ", transliterate(transliterator, "ふ\u309B"));
        assertEquals("べ", transliterate(transliterator, "へ\u309B"));
        assertEquals("ぼ", transliterate(transliterator, "ほ\u309B"));

        assertEquals("ゔ", transliterate(transliterator, "う\u309B"));
        assertEquals("ゞ", transliterate(transliterator, "ゝ\u309B"));
    }

    @Test
    public void testHiraganaWithNonCombiningSemiVoicedMark() {
        assertEquals("ぱ", transliterate(transliterator, "は\u309C"));
        assertEquals("ぴ", transliterate(transliterator, "ひ\u309C"));
        assertEquals("ぷ", transliterate(transliterator, "ふ\u309C"));
        assertEquals("ぺ", transliterate(transliterator, "へ\u309C"));
        assertEquals("ぽ", transliterate(transliterator, "ほ\u309C"));
    }

    @Test
    public void testKatakanaWithNonCombiningVoicedMark() {
        assertEquals("ガ", transliterate(transliterator, "カ\u309B"));
        assertEquals("ギ", transliterate(transliterator, "キ\u309B"));
        assertEquals("グ", transliterate(transliterator, "ク\u309B"));
        assertEquals("ゲ", transliterate(transliterator, "ケ\u309B"));
        assertEquals("ゴ", transliterate(transliterator, "コ\u309B"));

        assertEquals("ザ", transliterate(transliterator, "サ\u309B"));
        assertEquals("ジ", transliterate(transliterator, "シ\u309B"));
        assertEquals("ズ", transliterate(transliterator, "ス\u309B"));
        assertEquals("ゼ", transliterate(transliterator, "セ\u309B"));
        assertEquals("ゾ", transliterate(transliterator, "ソ\u309B"));

        assertEquals("ダ", transliterate(transliterator, "タ\u309B"));
        assertEquals("ヂ", transliterate(transliterator, "チ\u309B"));
        assertEquals("ヅ", transliterate(transliterator, "ツ\u309B"));
        assertEquals("デ", transliterate(transliterator, "テ\u309B"));
        assertEquals("ド", transliterate(transliterator, "ト\u309B"));

        assertEquals("バ", transliterate(transliterator, "ハ\u309B"));
        assertEquals("ビ", transliterate(transliterator, "ヒ\u309B"));
        assertEquals("ブ", transliterate(transliterator, "フ\u309B"));
        assertEquals("ベ", transliterate(transliterator, "ヘ\u309B"));
        assertEquals("ボ", transliterate(transliterator, "ホ\u309B"));
    }

    @Test
    public void testSpecialKatakanaWithNonCombiningVoicedMark() {
        assertEquals("ヴ", transliterate(transliterator, "ウ\u309B"));
        assertEquals("ヷ", transliterate(transliterator, "ワ\u309B"));
        assertEquals("ヸ", transliterate(transliterator, "ヰ\u309B"));
        assertEquals("ヹ", transliterate(transliterator, "ヱ\u309B"));
        assertEquals("ヺ", transliterate(transliterator, "ヲ\u309B"));
        assertEquals("ヾ", transliterate(transliterator, "ヽ\u309B"));
    }

    @Test
    public void testKatakanaWithNonCombiningSemiVoicedMark() {
        assertEquals("パ", transliterate(transliterator, "ハ\u309C"));
        assertEquals("ピ", transliterate(transliterator, "ヒ\u309C"));
        assertEquals("プ", transliterate(transliterator, "フ\u309C"));
        assertEquals("ペ", transliterate(transliterator, "ヘ\u309C"));
        assertEquals("ポ", transliterate(transliterator, "ホ\u309C"));
    }

    @Test
    public void testMixedNonCombiningMarks() {
        String input = "はは\u309Bは\u309Cひふへほ";
        String expected = "はばぱひふへほ";
        assertEquals(expected, transliterate(transliterator, input));
    }

    // --- Combining marks (U+3099, U+309A) via NFC chaining ---
    // These tests demonstrate that combining marks are handled by ::NFC;

    @Test
    public void testCombiningMarksWithNfc() {
        assertEquals("が", transliterate(transliteratorWithNfc, "か\u3099"));
        assertEquals("ぎ", transliterate(transliteratorWithNfc, "き\u3099"));
        assertEquals("ば", transliterate(transliteratorWithNfc, "は\u3099"));
        assertEquals("ぱ", transliterate(transliteratorWithNfc, "は\u309A"));

        assertEquals("ガ", transliterate(transliteratorWithNfc, "カ\u3099"));
        assertEquals("パ", transliterate(transliteratorWithNfc, "ハ\u309A"));
        assertEquals("ヴ", transliterate(transliteratorWithNfc, "ウ\u3099"));
    }

    @Test
    public void testCombiningMarksAloneNotHandled() {
        // Without NFC chaining, combining marks pass through
        // (they are not in the rule set)
        String input = "か\u3099";
        String result = transliterate(transliterator, input);
        // The result contains か + combining mark (not composed)
        assertNotEquals("が", result);
    }

    @Test
    public void testBothMarkTypesWithNfc() {
        // Mix of non-combining and combining marks
        String input = "か\u309Bき\u3099";
        assertEquals("がぎ", transliterate(transliteratorWithNfc, input));
    }

    // --- Edge cases ---

    @Test
    public void testEmptyString() {
        assertEquals("", transliterate(transliterator, ""));
    }

    @Test
    public void testNoMarks() {
        String input = "これはテストです";
        assertEquals(input, transliterate(transliterator, input));
    }

    @Test
    public void testInvalidNonCombiningCombinations() {
        // Non-combining marks after chars that can't be voiced/semi-voiced
        // should leave both characters as-is
        assertEquals("あ\u309B", transliterate(transliterator, "あ\u309B"));
        assertEquals("ん\u309B", transliterate(transliterator, "ん\u309B"));
        assertEquals("ア\u309C", transliterate(transliterator, "ア\u309C"));
    }
}
