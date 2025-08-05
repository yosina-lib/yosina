package lib.yosina.transliterators;

import static org.junit.jupiter.api.Assertions.*;

import java.util.List;
import lib.yosina.ChainedTransliterator;
import lib.yosina.CharIterator;
import lib.yosina.Chars;
import org.junit.jupiter.api.Test;

/** Tests for combined transliterator operations based on JavaScript test patterns. */
public class CombinedTransliteratorsTest {

    @Test
    public void testIvsSvsBaseWithKanjiOldNewCombination() {
        // This test replicates the JavaScript combinationTest1
        // Input: "檜" -> IVS/SVS -> Kanji Old-New -> IVS/SVS base mode -> expected: "桧"

        IvsSvsBaseTransliterator ivsToSvs =
                new IvsSvsBaseTransliterator(
                        new IvsSvsBaseTransliterator.Options(
                                IvsSvsBaseTransliterator.Mode.IVS_OR_SVS,
                                false,
                                IvsSvsBaseTransliterator.Charset.UNIJIS_2004,
                                false));

        KanjiOldNewTransliterator kanjiOldNew = new KanjiOldNewTransliterator();
        IvsSvsBaseTransliterator svsToBase =
                new IvsSvsBaseTransliterator(
                        new IvsSvsBaseTransliterator.Options(
                                IvsSvsBaseTransliterator.Mode.BASE,
                                false,
                                IvsSvsBaseTransliterator.Charset.UNIJIS_2004,
                                false));

        String input = "檜"; // U+6A9C

        // Step 1: Apply IVS/SVS addition
        CharIterator result1 = ivsToSvs.transliterate(Chars.of(input).iterator());

        // Step 2: Apply Kanji Old-New conversion
        CharIterator result2 = kanjiOldNew.transliterate(result1);

        // Step 3: Apply IVS/SVS base mode (remove selectors)
        CharIterator result3 = svsToBase.transliterate(result2);
        String output = result3.string();

        assertEquals("桧", output, "Combined IVS/SVS and Kanji Old-New should convert 檜 to 桧");
    }

    @Test
    public void testChainedTransliteratorWithMultipleSteps() {
        // Test using ChainedTransliterator for the same operation
        ChainedTransliterator chained =
                new ChainedTransliterator(
                        new IvsSvsBaseTransliterator(
                                new IvsSvsBaseTransliterator.Options(
                                        IvsSvsBaseTransliterator.Mode.IVS_OR_SVS,
                                        false,
                                        IvsSvsBaseTransliterator.Charset.UNIJIS_2004,
                                        false)),
                        new KanjiOldNewTransliterator(),
                        new IvsSvsBaseTransliterator(
                                new IvsSvsBaseTransliterator.Options(
                                        IvsSvsBaseTransliterator.Mode.BASE,
                                        false,
                                        IvsSvsBaseTransliterator.Charset.UNIJIS_2004,
                                        false)));

        String input = "檜";
        CharIterator result = chained.transliterate(Chars.of(input).iterator());
        String output = result.string();

        assertEquals(
                "桧", output, "ChainedTransliterator should produce same result as manual chaining");
    }

    @Test
    public void testSpacesAndHyphensNormalization() {
        HyphensTransliterator hyphens =
                new HyphensTransliterator(
                        new HyphensTransliterator.Options(
                                List.of(HyphensTransliterator.Mapping.JISX0208_90)));
        SpacesTransliterator spaces = new SpacesTransliterator();

        String input = "hello\uff70world　test\u30fcdata";

        // Apply hyphens first
        CharIterator result1 = hyphens.transliterate(Chars.of(input).iterator());

        // Then apply spaces
        CharIterator result2 = spaces.transliterate(result1);
        String output = result2.string();

        assertEquals(
                "hello\u30fcworld test\u30fcdata",
                output,
                "Should normalize both hyphens and spaces");
    }

    @Test
    public void testMathematicalAndRadicalsNormalization() {
        MathematicalAlphanumericsTransliterator math =
                new MathematicalAlphanumericsTransliterator();
        RadicalsTransliterator radicals = new RadicalsTransliterator();

        String input = "𝐀𝐁𝐂⼀⼆⼃";

        // Apply mathematical first
        CharIterator result1 = math.transliterate(Chars.of(input).iterator());

        // Then apply radicals
        CharIterator result2 = radicals.transliterate(result1);
        String output = result2.string();

        assertEquals("ABC一二丿", output, "Should normalize both mathematical and radical characters");
    }

    @Test
    public void testOptionsEqualsReflexivity() {
        HiraKataCompositionTransliterator.Options options =
                new HiraKataCompositionTransliterator.Options(true);
        assertEquals(options, options);
    }

    @Test
    public void testOptionsEqualsNullAndDifferentClass() {
        HiraKataCompositionTransliterator.Options options =
                new HiraKataCompositionTransliterator.Options(true);
        assertNotEquals(options, null);
        assertNotEquals(options, "some string");
    }
}
