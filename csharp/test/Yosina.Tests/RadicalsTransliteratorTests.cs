// Copyright (c) Yosina. All rights reserved.

using Yosina.Transliterators;

namespace Yosina.Tests;

/// <summary>
/// Tests for RadicalsTransliterator based on Java test patterns.
/// </summary>
public class RadicalsTransliteratorTests
{
    private static string Transliterate(string input)
    {
        var transliterator = new RadicalsTransliterator();
        var charList = Characters.CharacterList(input);
        return transliterator.Transliterate(charList).AsString();
    }

    [Theory]

    // CJK Radicals Supplement (⺀-⻳)
    [InlineData("冫", "⺀")]
    [InlineData("厂", "⺁")]
    [InlineData("乛", "⺂")]
    [InlineData("乚", "⺃")]
    [InlineData("乙", "⺄")]
    [InlineData("亻", "⺅")]
    [InlineData("冂", "⺆")]
    [InlineData("刂", "⺉")]
    [InlineData("卜", "⺊")]
    [InlineData("㔾", "⺋")]
    [InlineData("忄", "⺖")]
    [InlineData("扌", "⺘")]
    [InlineData("攵", "⺙")]
    [InlineData("氵", "⺡")]
    [InlineData("灬", "⺣")]
    [InlineData("爫", "⺥")]
    [InlineData("犭", "⺨")]
    [InlineData("礻", "⺭")]
    [InlineData("糹", "⺯")]
    [InlineData("纟", "⺰")]
    [InlineData("艹", "⺾")]
    [InlineData("艹", "⺿")]
    [InlineData("艹", "⻀")]
    [InlineData("衤", "⻂")]
    [InlineData("讠", "⻈")]
    [InlineData("贝", "⻉")]
    [InlineData("车", "⻋")]
    [InlineData("辶", "⻍")]
    [InlineData("阝", "⻏")]
    [InlineData("钅", "⻐")]
    [InlineData("阝", "⻖")]
    [InlineData("飠", "⻟")]
    [InlineData("饣", "⻠")]
    [InlineData("马", "⻢")]
    [InlineData("鱼", "⻥")]
    [InlineData("鸟", "⻦")]

    // Kangxi Radicals (⼀-⿕)
    [InlineData("一", "⼀")]
    [InlineData("丨", "⼁")]
    [InlineData("丶", "⼂")]
    [InlineData("丿", "⼃")]
    [InlineData("乙", "⼄")]
    [InlineData("亅", "⼅")]
    [InlineData("二", "⼆")]
    [InlineData("亠", "⼇")]
    [InlineData("人", "⼈")]
    [InlineData("儿", "⼉")]
    [InlineData("入", "⼊")]
    [InlineData("八", "⼋")]
    [InlineData("冂", "⼌")]
    [InlineData("冖", "⼍")]
    [InlineData("冫", "⼎")]
    [InlineData("几", "⼏")]
    [InlineData("凵", "⼐")]
    [InlineData("刀", "⼑")]
    [InlineData("力", "⼒")]
    [InlineData("勹", "⼓")]
    [InlineData("匕", "⼔")]
    [InlineData("匚", "⼕")]
    [InlineData("匸", "⼖")]
    [InlineData("十", "⼗")]
    [InlineData("卜", "⼘")]
    [InlineData("卩", "⼙")]
    [InlineData("厂", "⼚")]
    [InlineData("厶", "⼛")]
    [InlineData("又", "⼜")]
    [InlineData("口", "⼝")]
    [InlineData("囗", "⼞")]
    [InlineData("土", "⼟")]
    [InlineData("士", "⼠")]
    [InlineData("夂", "⼡")]
    [InlineData("夊", "⼢")]
    [InlineData("夕", "⼣")]
    [InlineData("大", "⼤")]
    [InlineData("女", "⼥")]
    [InlineData("子", "⼦")]
    [InlineData("宀", "⼧")]
    [InlineData("寸", "⼨")]
    [InlineData("小", "⼩")]
    [InlineData("尢", "⼪")]
    [InlineData("尸", "⼫")]
    [InlineData("屮", "⼬")]
    [InlineData("山", "⼭")]
    [InlineData("巛", "⼮")]
    [InlineData("工", "⼯")]
    [InlineData("己", "⼰")]
    [InlineData("巾", "⼱")]
    [InlineData("干", "⼲")]
    [InlineData("幺", "⼳")]
    [InlineData("广", "⼴")]
    [InlineData("廴", "⼵")]
    [InlineData("廾", "⼶")]
    [InlineData("弋", "⼷")]
    [InlineData("弓", "⼸")]
    [InlineData("彐", "⼹")]
    [InlineData("彡", "⼺")]
    [InlineData("彳", "⼻")]
    [InlineData("心", "⼼")]
    [InlineData("戈", "⼽")]
    [InlineData("戶", "⼾")]
    [InlineData("手", "⼿")]
    [InlineData("支", "⽀")]
    [InlineData("攴", "⽁")]
    [InlineData("文", "⽂")]
    [InlineData("斗", "⽃")]
    [InlineData("斤", "⽄")]
    [InlineData("方", "⽅")]
    [InlineData("无", "⽆")]
    [InlineData("日", "⽇")]
    [InlineData("曰", "⽈")]
    [InlineData("月", "⽉")]
    [InlineData("木", "⽊")]
    [InlineData("欠", "⽋")]
    [InlineData("止", "⽌")]
    [InlineData("歹", "⽍")]
    [InlineData("殳", "⽎")]
    [InlineData("毋", "⽏")]
    [InlineData("比", "⽐")]
    [InlineData("毛", "⽑")]
    [InlineData("氏", "⽒")]
    [InlineData("气", "⽓")]
    [InlineData("水", "⽔")]
    [InlineData("火", "⽕")]
    [InlineData("爪", "⽖")]
    [InlineData("父", "⽗")]
    [InlineData("爻", "⽘")]
    [InlineData("爿", "⽙")]
    [InlineData("片", "⽚")]
    [InlineData("牙", "⽛")]
    [InlineData("牛", "⽜")]
    [InlineData("犬", "⽝")]
    public void TestRadicalsTransliterations(string expected, string input)
    {
        var output = Transliterate(input);
        Assert.Equal(expected, output);
    }

    [Fact]
    public void TestEmptyString()
    {
        var output = Transliterate(string.Empty);
        Assert.Equal(string.Empty, output);
    }

    [Fact]
    public void TestUnmappedCharacters()
    {
        var input = "hello world 123 abc こんにちは 漢字";
        var output = Transliterate(input);
        Assert.Equal(input, output);
    }

    [Fact]
    public void TestMixedRadicalsContent()
    {
        var input = "部首⺀漢字⼀";
        var expected = "部首冫漢字一";
        var output = Transliterate(input);
        Assert.Equal(expected, output);
    }

    [Fact]
    public void TestKangxiRadicalsSequence()
    {
        var input = "⼀⼆⼃⼄⼅⼆⼇⼈⼉⼊";
        var expected = "一二丿乙亅二亠人儿入";
        var output = Transliterate(input);
        Assert.Equal(expected, output);
    }

    [Fact]
    public void TestCJKRadicalsSupplementSequence()
    {
        var input = "⺀⺁⺂⺃⺄⺅⺆";
        var expected = "冫厂乛乚乙亻冂";
        var output = Transliterate(input);
        Assert.Equal(expected, output);
    }

    [Fact]
    public void TestHandRadicalVariants()
    {
        var input = "⺘⼿"; // Hand radical variant and Kangxi hand radical
        var expected = "扌手";
        var output = Transliterate(input);
        Assert.Equal(expected, output);
    }

    [Fact]
    public void TestWaterRadicalVariants()
    {
        var input = "⺡⽔"; // Water radical variant and Kangxi water radical
        var expected = "氵水";
        var output = Transliterate(input);
        Assert.Equal(expected, output);
    }

    [Fact]
    public void TestGrassRadicalVariants()
    {
        var input = "⺾⺿⻀⾋"; // Different grass radical variants
        var expected = "艹艹艹艸";
        var output = Transliterate(input);
        Assert.Equal(expected, output);
    }

    [Fact]
    public void TestSimplifiedRadicals()
    {
        var input = "⻈⻉⻋⻐⻢⻥⻦"; // Simplified radicals
        var expected = "讠贝车钅马鱼鸟";
        var output = Transliterate(input);
        Assert.Equal(expected, output);
    }

    [Fact]
    public void TestRadicalsInContext()
    {
        var input = "⼭の⽊を⽔で育てる";
        var expected = "山の木を水で育てる";
        var output = Transliterate(input);
        Assert.Equal(expected, output);
    }
}
