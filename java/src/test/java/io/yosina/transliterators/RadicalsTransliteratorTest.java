package io.yosina.transliterators;

import static org.junit.jupiter.api.Assertions.*;

import io.yosina.CharIterator;
import io.yosina.Chars;
import java.util.stream.Stream;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.Arguments;
import org.junit.jupiter.params.provider.MethodSource;

/** Tests for RadicalsTransliterator based on JavaScript test patterns. */
public class RadicalsTransliteratorTest {

    private static Stream<Arguments> radicalsTestCases() {
        return Stream.of(
                // CJK Radicals Supplement (⺀-⻳)
                Arguments.of("冫", "⺀", "Radical ice (variant) to standard ice"),
                Arguments.of("厂", "⺁", "Radical cliff (variant) to standard cliff"),
                Arguments.of("乛", "⺂", "Radical second (variant) to standard second"),
                Arguments.of("乚", "⺃", "Radical second three (variant) to standard"),
                Arguments.of("乙", "⺄", "Radical second (variant) to standard second"),
                Arguments.of("亻", "⺅", "Radical person (variant) to standard person"),
                Arguments.of("冂", "⺆", "Radical wide (variant) to standard wide"),
                Arguments.of("刂", "⺉", "Radical knife (variant) to standard knife"),
                Arguments.of("卜", "⺊", "Radical divination (variant) to standard"),
                Arguments.of("㔾", "⺋", "Radical seal (variant) to standard seal"),
                Arguments.of("忄", "⺖", "Radical heart (variant) to standard heart"),
                Arguments.of("扌", "⺘", "Radical hand (variant) to standard hand"),
                Arguments.of("攵", "⺙", "Radical rap (variant) to standard rap"),
                Arguments.of("氵", "⺡", "Radical water (variant) to standard water"),
                Arguments.of("灬", "⺣", "Radical fire (variant) to standard fire"),
                Arguments.of("爫", "⺥", "Radical claw (variant) to standard claw"),
                Arguments.of("犭", "⺨", "Radical dog (variant) to standard dog"),
                Arguments.of("礻", "⺭", "Radical spirit (variant) to standard spirit"),
                Arguments.of("糹", "⺯", "Radical silk (variant) to standard silk"),
                Arguments.of("纟", "⺰", "Radical silk simplified (variant) to standard"),
                Arguments.of("艹", "⺾", "Radical grass (variant) to standard grass"),
                Arguments.of("艹", "⺿", "Radical grass (variant 2) to standard grass"),
                Arguments.of("艹", "⻀", "Radical grass (variant 3) to standard grass"),
                Arguments.of("衤", "⻂", "Radical clothes (variant) to standard clothes"),
                Arguments.of("讠", "⻈", "Radical speech simplified (variant) to standard"),
                Arguments.of("贝", "⻉", "Radical shell simplified (variant) to standard"),
                Arguments.of("车", "⻋", "Radical vehicle simplified (variant) to standard"),
                Arguments.of("辶", "⻍", "Radical walk (variant) to standard walk"),
                Arguments.of("阝", "⻏", "Radical city (variant) to standard city"),
                Arguments.of("钅", "⻐", "Radical metal simplified (variant) to standard"),
                Arguments.of("阝", "⻖", "Radical mound (variant) to standard mound"),
                Arguments.of("飠", "⻟", "Radical eat (variant) to standard eat"),
                Arguments.of("饣", "⻠", "Radical eat simplified (variant) to standard"),
                Arguments.of("马", "⻢", "Radical horse simplified (variant) to standard"),
                Arguments.of("鱼", "⻥", "Radical fish simplified (variant) to standard"),
                Arguments.of("鸟", "⻦", "Radical bird simplified (variant) to standard"),

                // Kangxi Radicals (⼀-⿕)
                Arguments.of("一", "⼀", "Kangxi radical one to standard one"),
                Arguments.of("丨", "⼁", "Kangxi radical line to standard line"),
                Arguments.of("丶", "⼂", "Kangxi radical dot to standard dot"),
                Arguments.of("丿", "⼃", "Kangxi radical slash to standard slash"),
                Arguments.of("乙", "⼄", "Kangxi radical second to standard second"),
                Arguments.of("亅", "⼅", "Kangxi radical hook to standard hook"),
                Arguments.of("二", "⼆", "Kangxi radical two to standard two"),
                Arguments.of("亠", "⼇", "Kangxi radical lid to standard lid"),
                Arguments.of("人", "⼈", "Kangxi radical person to standard person"),
                Arguments.of("儿", "⼉", "Kangxi radical legs to standard legs"),
                Arguments.of("入", "⼊", "Kangxi radical enter to standard enter"),
                Arguments.of("八", "⼋", "Kangxi radical eight to standard eight"),
                Arguments.of("冂", "⼌", "Kangxi radical down box to standard down box"),
                Arguments.of("冖", "⼍", "Kangxi radical cover to standard cover"),
                Arguments.of("冫", "⼎", "Kangxi radical ice to standard ice"),
                Arguments.of("几", "⼏", "Kangxi radical table to standard table"),
                Arguments.of("凵", "⼐", "Kangxi radical open box to standard open box"),
                Arguments.of("刀", "⼑", "Kangxi radical knife to standard knife"),
                Arguments.of("力", "⼒", "Kangxi radical power to standard power"),
                Arguments.of("勹", "⼓", "Kangxi radical wrap to standard wrap"),
                Arguments.of("匕", "⼔", "Kangxi radical spoon to standard spoon"),
                Arguments.of("匚", "⼕", "Kangxi radical right open box to standard"),
                Arguments.of("匸", "⼖", "Kangxi radical hiding enclosure to standard"),
                Arguments.of("十", "⼗", "Kangxi radical ten to standard ten"),
                Arguments.of("卜", "⼘", "Kangxi radical divination to standard divination"),
                Arguments.of("卩", "⼙", "Kangxi radical seal to standard seal"),
                Arguments.of("厂", "⼚", "Kangxi radical cliff to standard cliff"),
                Arguments.of("厶", "⼛", "Kangxi radical private to standard private"),
                Arguments.of("又", "⼜", "Kangxi radical again to standard again"),
                Arguments.of("口", "⼝", "Kangxi radical mouth to standard mouth"),
                Arguments.of("囗", "⼞", "Kangxi radical enclosure to standard enclosure"),
                Arguments.of("土", "⼟", "Kangxi radical earth to standard earth"),
                Arguments.of("士", "⼠", "Kangxi radical scholar to standard scholar"),
                Arguments.of("夂", "⼡", "Kangxi radical go to standard go"),
                Arguments.of("夊", "⼢", "Kangxi radical go slowly to standard go slowly"),
                Arguments.of("夕", "⼣", "Kangxi radical evening to standard evening"),
                Arguments.of("大", "⼤", "Kangxi radical big to standard big"),
                Arguments.of("女", "⼥", "Kangxi radical woman to standard woman"),
                Arguments.of("子", "⼦", "Kangxi radical child to standard child"),
                Arguments.of("宀", "⼧", "Kangxi radical roof to standard roof"),
                Arguments.of("寸", "⼨", "Kangxi radical inch to standard inch"),
                Arguments.of("小", "⼩", "Kangxi radical small to standard small"),
                Arguments.of("尢", "⼪", "Kangxi radical lame to standard lame"),
                Arguments.of("尸", "⼫", "Kangxi radical corpse to standard corpse"),
                Arguments.of("屮", "⼬", "Kangxi radical sprout to standard sprout"),
                Arguments.of("山", "⼭", "Kangxi radical mountain to standard mountain"),
                Arguments.of("巛", "⼮", "Kangxi radical river to standard river"),
                Arguments.of("工", "⼯", "Kangxi radical work to standard work"),
                Arguments.of("己", "⼰", "Kangxi radical oneself to standard oneself"),
                Arguments.of("巾", "⼱", "Kangxi radical turban to standard turban"),
                Arguments.of("干", "⼲", "Kangxi radical dry to standard dry"),
                Arguments.of("幺", "⼳", "Kangxi radical short thread to standard"),
                Arguments.of("广", "⼴", "Kangxi radical dotted cliff to standard"),
                Arguments.of("廴", "⼵", "Kangxi radical long stride to standard"),
                Arguments.of("廾", "⼶", "Kangxi radical arch to standard arch"),
                Arguments.of("弋", "⼷", "Kangxi radical shoot to standard shoot"),
                Arguments.of("弓", "⼸", "Kangxi radical bow to standard bow"),
                Arguments.of("彐", "⼹", "Kangxi radical snout to standard snout"),
                Arguments.of("彡", "⼺", "Kangxi radical bristle to standard bristle"),
                Arguments.of("彳", "⼻", "Kangxi radical step to standard step"),
                Arguments.of("心", "⼼", "Kangxi radical heart to standard heart"),
                Arguments.of("戈", "⼽", "Kangxi radical halberd to standard halberd"),
                Arguments.of("戶", "⼾", "Kangxi radical door to standard door"),
                Arguments.of("手", "⼿", "Kangxi radical hand to standard hand"),
                Arguments.of("支", "⽀", "Kangxi radical branch to standard branch"),
                Arguments.of("攴", "⽁", "Kangxi radical rap to standard rap"),
                Arguments.of("文", "⽂", "Kangxi radical script to standard script"),
                Arguments.of("斗", "⽃", "Kangxi radical dipper to standard dipper"),
                Arguments.of("斤", "⽄", "Kangxi radical axe to standard axe"),
                Arguments.of("方", "⽅", "Kangxi radical square to standard square"),
                Arguments.of("无", "⽆", "Kangxi radical not to standard not"),
                Arguments.of("日", "⽇", "Kangxi radical sun to standard sun"),
                Arguments.of("曰", "⽈", "Kangxi radical say to standard say"),
                Arguments.of("月", "⽉", "Kangxi radical moon to standard moon"),
                Arguments.of("木", "⽊", "Kangxi radical tree to standard tree"),
                Arguments.of("欠", "⽋", "Kangxi radical lack to standard lack"),
                Arguments.of("止", "⽌", "Kangxi radical stop to standard stop"),
                Arguments.of("歹", "⽍", "Kangxi radical death to standard death"),
                Arguments.of("殳", "⽎", "Kangxi radical weapon to standard weapon"),
                Arguments.of("毋", "⽏", "Kangxi radical do not to standard do not"),
                Arguments.of("比", "⽐", "Kangxi radical compare to standard compare"),
                Arguments.of("毛", "⽑", "Kangxi radical fur to standard fur"),
                Arguments.of("氏", "⽒", "Kangxi radical clan to standard clan"),
                Arguments.of("气", "⽓", "Kangxi radical steam to standard steam"),
                Arguments.of("水", "⽔", "Kangxi radical water to standard water"),
                Arguments.of("火", "⽕", "Kangxi radical fire to standard fire"),
                Arguments.of("爪", "⽖", "Kangxi radical claw to standard claw"),
                Arguments.of("父", "⽗", "Kangxi radical father to standard father"),
                Arguments.of("爻", "⽘", "Kangxi radical double x to standard double x"),
                Arguments.of("爿", "⽙", "Kangxi radical half tree trunk to standard"),
                Arguments.of("片", "⽚", "Kangxi radical slice to standard slice"),
                Arguments.of("牙", "⽛", "Kangxi radical fang to standard fang"),
                Arguments.of("牛", "⽜", "Kangxi radical cow to standard cow"),
                Arguments.of("犬", "⽝", "Kangxi radical dog to standard dog"));
    }

    @ParameterizedTest(name = "Radicals test case: {2}")
    @MethodSource("radicalsTestCases")
    public void testRadicalsTransliterations(String expected, String input, String description) {
        RadicalsTransliterator transliterator = new RadicalsTransliterator();

        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());
        String output = result.string();

        assertEquals(expected, output, description);
    }

    @Test
    public void testEmptyString() {
        RadicalsTransliterator transliterator = new RadicalsTransliterator();

        CharIterator result = transliterator.transliterate(Chars.of("").iterator());
        String output = result.string();

        assertEquals("", output);
    }

    @Test
    public void testUnmappedCharacters() {
        RadicalsTransliterator transliterator = new RadicalsTransliterator();

        String input = "hello world 123 abc こんにちは 漢字";
        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());
        String output = result.string();

        assertEquals(input, output, "Unmapped characters should remain unchanged");
    }

    @Test
    public void testMixedRadicalsContent() {
        RadicalsTransliterator transliterator = new RadicalsTransliterator();

        String input = "部首⺀漢字⼀";
        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());
        String output = result.string();

        assertEquals("部首冫漢字一", output, "Should convert radicals while preserving other characters");
    }

    @Test
    public void testKangxiRadicalsSequence() {
        RadicalsTransliterator transliterator = new RadicalsTransliterator();

        String input = "⼀⼆⼃⼄⼅⼆⼇⼈⼉⼊";
        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());

        String output = result.string();

        assertEquals("一二丿乙亅二亠人儿入", output, "Should convert sequence of Kangxi radicals");
    }

    @Test
    public void testCJKRadicalsSupplementSequence() {
        RadicalsTransliterator transliterator = new RadicalsTransliterator();

        String input = "⺀⺁⺂⺃⺄⺅⺆";
        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());

        String output = result.string();

        assertEquals("冫厂乛乚乙亻冂", output, "Should convert sequence of CJK radicals supplement");
    }

    @Test
    public void testHandRadicalVariants() {
        RadicalsTransliterator transliterator = new RadicalsTransliterator();

        String input = "⺘⼿"; // Hand radical variant and Kangxi hand radical
        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());

        String output = result.string();

        assertEquals("扌手", output, "Should convert different hand radical forms");
    }

    @Test
    public void testWaterRadicalVariants() {
        RadicalsTransliterator transliterator = new RadicalsTransliterator();

        String input = "⺡⽔"; // Water radical variant and Kangxi water radical
        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());

        String output = result.string();

        assertEquals("氵水", output, "Should convert different water radical forms");
    }

    @Test
    public void testGrassRadicalVariants() {
        RadicalsTransliterator transliterator = new RadicalsTransliterator();

        String input = "⺾⺿⻀⾋"; // Different grass radical variants
        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());

        String output = result.string();

        assertEquals("艹艹艹艸", output, "Should convert all grass radical variants");
    }

    @Test
    public void testSimplifiedRadicals() {
        RadicalsTransliterator transliterator = new RadicalsTransliterator();

        String input = "⻈⻉⻋⻐⻢⻥⻦"; // Simplified radicals
        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());

        String output = result.string();

        assertEquals("讠贝车钅马鱼鸟", output, "Should convert simplified radical forms");
    }

    @Test
    public void testRadicalsInContext() {
        RadicalsTransliterator transliterator = new RadicalsTransliterator();

        String input = "⼭の⽊を⽔で育てる";
        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());

        String output = result.string();

        assertEquals("山の木を水で育てる", output, "Should convert radicals in natural text context");
    }

    @Test
    public void testIteratorProperties() {
        RadicalsTransliterator transliterator = new RadicalsTransliterator();

        String input = "⼀⼆⼃";
        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());

        assertNotNull(result);
        assertTrue(result.hasNext());
    }
}
