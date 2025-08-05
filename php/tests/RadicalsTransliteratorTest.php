<?php

declare(strict_types=1);

use PHPUnit\Framework\Attributes\DataProvider;
use PHPUnit\Framework\TestCase;

use Yosina\Chars;
use Yosina\TransliteratorInterface;
use Yosina\TransliteratorRegistry;
use Yosina\Transliterators\RadicalsTransliterator;

/**
 * Tests for RadicalsTransliterator based on Java test cases.
 */
class RadicalsTransliteratorTest extends TestCase
{
    /**
     * Test cases for radicals transliterations.
     * @return array<array{string, string, string}>
     */
    public static function radicalsProvider(): array
    {
        return [
            // CJK Radicals Supplement (⺀-⻳)
            ["冫", "⺀", "Radical ice (variant) to standard ice"],
            ["厂", "⺁", "Radical cliff (variant) to standard cliff"],
            ["乛", "⺂", "Radical second (variant) to standard second"],
            ["乚", "⺃", "Radical second three (variant) to standard"],
            ["乙", "⺄", "Radical second (variant) to standard second"],
            ["亻", "⺅", "Radical person (variant) to standard person"],
            ["冂", "⺆", "Radical wide (variant) to standard wide"],
            ["刂", "⺉", "Radical knife (variant) to standard knife"],
            ["卜", "⺊", "Radical divination (variant) to standard"],
            ["㔾", "⺋", "Radical seal (variant) to standard seal"],
            ["忄", "⺖", "Radical heart (variant) to standard heart"],
            ["扌", "⺘", "Radical hand (variant) to standard hand"],
            ["攵", "⺙", "Radical rap (variant) to standard rap"],
            ["氵", "⺡", "Radical water (variant) to standard water"],
            ["灬", "⺣", "Radical fire (variant) to standard fire"],
            ["爫", "⺥", "Radical claw (variant) to standard claw"],
            ["犭", "⺨", "Radical dog (variant) to standard dog"],
            ["礻", "⺭", "Radical spirit (variant) to standard spirit"],
            ["糹", "⺯", "Radical silk (variant) to standard silk"],
            ["纟", "⺰", "Radical silk simplified (variant) to standard"],
            ["艹", "⺾", "Radical grass (variant) to standard grass"],
            ["艹", "⺿", "Radical grass (variant 2) to standard grass"],
            ["艹", "⻀", "Radical grass (variant 3) to standard grass"],
            ["衤", "⻂", "Radical clothes (variant) to standard clothes"],
            ["讠", "⻈", "Radical speech simplified (variant) to standard"],
            ["贝", "⻉", "Radical shell simplified (variant) to standard"],
            ["车", "⻋", "Radical vehicle simplified (variant) to standard"],
            ["辶", "⻍", "Radical walk (variant) to standard walk"],
            ["阝", "⻏", "Radical city (variant) to standard city"],
            ["钅", "⻐", "Radical metal simplified (variant) to standard"],
            ["阝", "⻖", "Radical mound (variant) to standard mound"],
            ["飠", "⻟", "Radical eat (variant) to standard eat"],
            ["饣", "⻠", "Radical eat simplified (variant) to standard"],
            ["马", "⻢", "Radical horse simplified (variant) to standard"],
            ["鱼", "⻥", "Radical fish simplified (variant) to standard"],
            ["鸟", "⻦", "Radical bird simplified (variant) to standard"],

            // Kangxi Radicals (⼀-⿕)
            ["一", "⼀", "Kangxi radical one to standard one"],
            ["丨", "⼁", "Kangxi radical line to standard line"],
            ["丶", "⼂", "Kangxi radical dot to standard dot"],
            ["丿", "⼃", "Kangxi radical slash to standard slash"],
            ["乙", "⼄", "Kangxi radical second to standard second"],
            ["亅", "⼅", "Kangxi radical hook to standard hook"],
            ["二", "⼆", "Kangxi radical two to standard two"],
            ["亠", "⼇", "Kangxi radical lid to standard lid"],
            ["人", "⼈", "Kangxi radical person to standard person"],
            ["儿", "⼉", "Kangxi radical legs to standard legs"],
            ["入", "⼊", "Kangxi radical enter to standard enter"],
            ["八", "⼋", "Kangxi radical eight to standard eight"],
            ["冂", "⼌", "Kangxi radical down box to standard down box"],
            ["冖", "⼍", "Kangxi radical cover to standard cover"],
            ["冫", "⼎", "Kangxi radical ice to standard ice"],
            ["几", "⼏", "Kangxi radical table to standard table"],
            ["凵", "⼐", "Kangxi radical open box to standard open box"],
            ["刀", "⼑", "Kangxi radical knife to standard knife"],
            ["力", "⼒", "Kangxi radical power to standard power"],
            ["勹", "⼓", "Kangxi radical wrap to standard wrap"],
            ["匕", "⼔", "Kangxi radical spoon to standard spoon"],
            ["匚", "⼕", "Kangxi radical right open box to standard"],
            ["匸", "⼖", "Kangxi radical hiding enclosure to standard"],
            ["十", "⼗", "Kangxi radical ten to standard ten"],
            ["卜", "⼘", "Kangxi radical divination to standard divination"],
            ["卩", "⼙", "Kangxi radical seal to standard seal"],
            ["厂", "⼚", "Kangxi radical cliff to standard cliff"],
            ["厶", "⼛", "Kangxi radical private to standard private"],
            ["又", "⼜", "Kangxi radical again to standard again"],
            ["口", "⼝", "Kangxi radical mouth to standard mouth"],
            ["囗", "⼞", "Kangxi radical enclosure to standard enclosure"],
            ["土", "⼟", "Kangxi radical earth to standard earth"],
            ["士", "⼠", "Kangxi radical scholar to standard scholar"],
            ["夂", "⼡", "Kangxi radical go to standard go"],
            ["夊", "⼢", "Kangxi radical go slowly to standard go slowly"],
            ["夕", "⼣", "Kangxi radical evening to standard evening"],
            ["大", "⼤", "Kangxi radical big to standard big"],
            ["女", "⼥", "Kangxi radical woman to standard woman"],
            ["子", "⼦", "Kangxi radical child to standard child"],
            ["宀", "⼧", "Kangxi radical roof to standard roof"],
            ["寸", "⼨", "Kangxi radical inch to standard inch"],
            ["小", "⼩", "Kangxi radical small to standard small"],
            ["尢", "⼪", "Kangxi radical lame to standard lame"],
            ["尸", "⼫", "Kangxi radical corpse to standard corpse"],
            ["屮", "⼬", "Kangxi radical sprout to standard sprout"],
            ["山", "⼭", "Kangxi radical mountain to standard mountain"],
            ["巛", "⼮", "Kangxi radical river to standard river"],
            ["工", "⼯", "Kangxi radical work to standard work"],
            ["己", "⼰", "Kangxi radical oneself to standard oneself"],
            ["巾", "⼱", "Kangxi radical turban to standard turban"],
            ["干", "⼲", "Kangxi radical dry to standard dry"],
            ["幺", "⼳", "Kangxi radical short thread to standard"],
            ["广", "⼴", "Kangxi radical dotted cliff to standard"],
            ["廴", "⼵", "Kangxi radical long stride to standard"],
            ["廾", "⼶", "Kangxi radical arch to standard arch"],
            ["弋", "⼷", "Kangxi radical shoot to standard shoot"],
            ["弓", "⼸", "Kangxi radical bow to standard bow"],
            ["彐", "⼹", "Kangxi radical snout to standard snout"],
            ["彡", "⼺", "Kangxi radical bristle to standard bristle"],
            ["彳", "⼻", "Kangxi radical step to standard step"],
            ["心", "⼼", "Kangxi radical heart to standard heart"],
            ["戈", "⼽", "Kangxi radical halberd to standard halberd"],
            ["戶", "⼾", "Kangxi radical door to standard door"],
            ["手", "⼿", "Kangxi radical hand to standard hand"],
            ["支", "⽀", "Kangxi radical branch to standard branch"],
            ["攴", "⽁", "Kangxi radical rap to standard rap"],
            ["文", "⽂", "Kangxi radical script to standard script"],
            ["斗", "⽃", "Kangxi radical dipper to standard dipper"],
            ["斤", "⽄", "Kangxi radical axe to standard axe"],
            ["方", "⽅", "Kangxi radical square to standard square"],
            ["无", "⽆", "Kangxi radical not to standard not"],
            ["日", "⽇", "Kangxi radical sun to standard sun"],
            ["曰", "⽈", "Kangxi radical say to standard say"],
            ["月", "⽉", "Kangxi radical moon to standard moon"],
            ["木", "⽊", "Kangxi radical tree to standard tree"],
            ["欠", "⽋", "Kangxi radical lack to standard lack"],
            ["止", "⽌", "Kangxi radical stop to standard stop"],
            ["歹", "⽍", "Kangxi radical death to standard death"],
            ["殳", "⽎", "Kangxi radical weapon to standard weapon"],
            ["毋", "⽏", "Kangxi radical do not to standard do not"],
            ["比", "⽐", "Kangxi radical compare to standard compare"],
            ["毛", "⽑", "Kangxi radical fur to standard fur"],
            ["氏", "⽒", "Kangxi radical clan to standard clan"],
            ["气", "⽓", "Kangxi radical steam to standard steam"],
            ["水", "⽔", "Kangxi radical water to standard water"],
            ["火", "⽕", "Kangxi radical fire to standard fire"],
            ["爪", "⽖", "Kangxi radical claw to standard claw"],
            ["父", "⽗", "Kangxi radical father to standard father"],
            ["爻", "⽘", "Kangxi radical double x to standard double x"],
            ["爿", "⽙", "Kangxi radical half tree trunk to standard"],
            ["片", "⽚", "Kangxi radical slice to standard slice"],
            ["牙", "⽛", "Kangxi radical fang to standard fang"],
            ["牛", "⽜", "Kangxi radical cow to standard cow"],
            ["犬", "⽝", "Kangxi radical dog to standard dog"],
        ];
    }

    #[DataProvider('radicalsProvider')]
    public function testRadicalsTransliterations(string $expected, string $input, string $description): void
    {
        $transliterator = new RadicalsTransliterator();

        $result = $this->processString($transliterator, $input);

        $this->assertEquals($expected, $result, $description);
    }

    public function testEmptyString(): void
    {
        $transliterator = new RadicalsTransliterator();

        $result = $this->processString($transliterator, "");

        $this->assertEquals("", $result);
    }

    public function testUnmappedCharacters(): void
    {
        $transliterator = new RadicalsTransliterator();

        $input = "hello world 123 abc こんにちは 漢字";
        $result = $this->processString($transliterator, $input);

        $this->assertEquals($input, $result, "Unmapped characters should remain unchanged");
    }

    public function testMixedRadicalsContent(): void
    {
        $transliterator = new RadicalsTransliterator();

        $input = "部首⺀漢字⼀";
        $expected = "部首冫漢字一";
        $result = $this->processString($transliterator, $input);

        $this->assertEquals($expected, $result, "Should convert radicals while preserving other characters");
    }

    public function testKangxiRadicalsSequence(): void
    {
        $transliterator = new RadicalsTransliterator();

        $input = "⼀⼆⼃⼄⼅⼆⼇⼈⼉⼊";
        $expected = "一二丿乙亅二亠人儿入";
        $result = $this->processString($transliterator, $input);

        $this->assertEquals($expected, $result, "Should convert sequence of Kangxi radicals");
    }

    public function testCJKRadicalsSupplementSequence(): void
    {
        $transliterator = new RadicalsTransliterator();

        $input = "⺀⺁⺂⺃⺄⺅⺆";
        $expected = "冫厂乛乚乙亻冂";
        $result = $this->processString($transliterator, $input);

        $this->assertEquals($expected, $result, "Should convert sequence of CJK radicals supplement");
    }

    public function testHandRadicalVariants(): void
    {
        $transliterator = new RadicalsTransliterator();

        $input = "⺘⼿"; // Hand radical variant and Kangxi hand radical
        $expected = "扌手";
        $result = $this->processString($transliterator, $input);

        $this->assertEquals($expected, $result, "Should convert different hand radical forms");
    }

    public function testWaterRadicalVariants(): void
    {
        $transliterator = new RadicalsTransliterator();

        $input = "⺡⽔"; // Water radical variant and Kangxi water radical
        $expected = "氵水";
        $result = $this->processString($transliterator, $input);

        $this->assertEquals($expected, $result, "Should convert different water radical forms");
    }

    public function testGrassRadicalVariants(): void
    {
        $transliterator = new RadicalsTransliterator();

        $input = "⺾⺿⻀⾋"; // Different grass radical variants
        $expected = "艹艹艹艸";
        $result = $this->processString($transliterator, $input);

        $this->assertEquals($expected, $result, "Should convert all grass radical variants");
    }

    public function testSimplifiedRadicals(): void
    {
        $transliterator = new RadicalsTransliterator();

        $input = "⻈⻉⻋⻐⻢⻥⻦"; // Simplified radicals
        $expected = "讠贝车钅马鱼鸟";
        $result = $this->processString($transliterator, $input);

        $this->assertEquals($expected, $result, "Should convert simplified radical forms");
    }

    public function testRadicalsInContext(): void
    {
        $transliterator = new RadicalsTransliterator();

        $input = "⼭の⽊を⽔で育てる";
        $expected = "山の木を水で育てる";
        $result = $this->processString($transliterator, $input);

        $this->assertEquals($expected, $result, "Should convert radicals in natural text context");
    }

    public function testRegistryIntegration(): void
    {
        // Test that the transliterator can be created via registry
        $factory = TransliteratorRegistry::getTransliteratorFactory('radicals');
        $transliterator = $factory([]);

        $input = "⼀";
        $expected = "一";
        $result = $this->processString($transliterator, $input);

        $this->assertEquals($expected, $result, "Registry integration failed");
    }

    public function testIteratorProperties(): void
    {
        $transliterator = new RadicalsTransliterator();

        $input = "⼀⼆⼃";
        $chars = Chars::buildCharArray($input);
        $result = $transliterator($chars);
        $this->assertEquals(['一', '二', "\u{4e3f}", ''], array_map(static fn ($c) => $c->c, iterator_to_array($result)));
    }

    private function processString(TransliteratorInterface $transliterator, string $input): string
    {
        $chars = Chars::buildCharArray($input);
        return Chars::fromChars($transliterator($chars));
    }
}