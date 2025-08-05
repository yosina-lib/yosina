<?php

namespace Yosina\Tests;

use PHPUnit\Framework\TestCase;
use Yosina\TransliterationRecipe;
use Yosina\Yosina;
use Yosina\Transliterators\HyphensTransliterator;
use Yosina\Transliterators\IvsSvsBaseTransliterator;

class TransliterationRecipeTest extends TestCase
{
    // Test basic recipe functionality
    public function testEmptyRecipe(): void
    {
        $recipe = new TransliterationRecipe();
        $configs = $recipe->buildTransliteratorConfigs();
        
        $this->assertIsArray($configs);
        $this->assertCount(0, $configs);
    }

    public function testDefaultValues(): void
    {
        $recipe = new TransliterationRecipe();
        
        $this->assertFalse($recipe->kanjiOldNew);
        $this->assertFalse($recipe->replaceSuspiciousHyphensToProlongedSoundMarks);
        $this->assertFalse($recipe->replaceCombinedCharacters);
        $this->assertFalse($recipe->replaceCircledOrSquaredCharacters);
        $this->assertFalse($recipe->replaceIdeographicAnnotations);
        $this->assertFalse($recipe->replaceRadicals);
        $this->assertFalse($recipe->replaceSpaces);
        $this->assertFalse($recipe->replaceHyphens);
        $this->assertFalse($recipe->replaceMathematicalAlphanumerics);
        $this->assertFalse($recipe->combineDecomposedHiraganasAndKatakanas);
        $this->assertFalse($recipe->toFullwidth);
        $this->assertFalse($recipe->toHalfwidth);
        $this->assertFalse($recipe->removeIvsSvs);
        $this->assertEquals('unijis_2004', $recipe->charset);
    }

    // Test individual transliterator configurations
    public function testKanjiOldNewWithIvsSvs(): void
    {
        $recipe = new TransliterationRecipe(kanjiOldNew: true);
        $configs = $recipe->buildTransliteratorConfigs();
        
        // Should contain kanji-old-new and IVS/SVS configurations
        $configNames = array_map(fn($c) => $c[0], $configs);
        $this->assertContains('kanji-old-new', $configNames);
        $this->assertContains('ivs-svs-base', $configNames);
        
        // Should have at least 3 configs: ivs-or-svs, kanji-old-new, base
        $this->assertGreaterThanOrEqual(3, count($configs));
    }

    public function testProlongedSoundMarks(): void
    {
        $recipe = new TransliterationRecipe(replaceSuspiciousHyphensToProlongedSoundMarks: true);
        $configs = $recipe->buildTransliteratorConfigs();
        
        $this->assertCount(1, $configs);
        $this->assertEquals('prolonged-sound-marks', $configs[0][0]);
        $this->assertNotEmpty($configs[0][1]);
        $this->assertTrue($configs[0][1]['replace_prolonged_marks_following_alnums']);
    }

    public function testCircledOrSquared(): void
    {
        $recipe = new TransliterationRecipe(replaceCircledOrSquaredCharacters: true);
        $configs = $recipe->buildTransliteratorConfigs();
        
        $this->assertCount(1, $configs);
        $this->assertEquals('circled-or-squared', $configs[0][0]);
        $this->assertNotEmpty($configs[0][1]);
        $this->assertTrue($configs[0][1]['includeEmojis']);
    }

    public function testCircledOrSquaredExcludeEmojis(): void
    {
        $recipe = new TransliterationRecipe(replaceCircledOrSquaredCharacters: 'exclude-emojis');
        $configs = $recipe->buildTransliteratorConfigs();
        
        $this->assertCount(1, $configs);
        $this->assertEquals('circled-or-squared', $configs[0][0]);
        $this->assertNotEmpty($configs[0][1]);
        $this->assertFalse($configs[0][1]['includeEmojis']);
    }

    public function testCombined(): void
    {
        $recipe = new TransliterationRecipe(replaceCombinedCharacters: true);
        $configs = $recipe->buildTransliteratorConfigs();
        
        $this->assertCount(1, $configs);
        $this->assertEquals('combined', $configs[0][0]);
    }

    public function testIdeographicAnnotations(): void
    {
        $recipe = new TransliterationRecipe(replaceIdeographicAnnotations: true);
        $configs = $recipe->buildTransliteratorConfigs();
        
        $this->assertCount(1, $configs);
        $this->assertEquals('ideographic-annotations', $configs[0][0]);
    }

    public function testRadicals(): void
    {
        $recipe = new TransliterationRecipe(replaceRadicals: true);
        $configs = $recipe->buildTransliteratorConfigs();
        
        $this->assertCount(1, $configs);
        $this->assertEquals('radicals', $configs[0][0]);
    }

    public function testSpaces(): void
    {
        $recipe = new TransliterationRecipe(replaceSpaces: true);
        $configs = $recipe->buildTransliteratorConfigs();
        
        $this->assertCount(1, $configs);
        $this->assertEquals('spaces', $configs[0][0]);
    }

    public function testMathematicalAlphanumerics(): void
    {
        $recipe = new TransliterationRecipe(replaceMathematicalAlphanumerics: true);
        $configs = $recipe->buildTransliteratorConfigs();
        
        $this->assertCount(1, $configs);
        $this->assertEquals('mathematical-alphanumerics', $configs[0][0]);
    }

    public function testHiraKataComposition(): void
    {
        $recipe = new TransliterationRecipe(combineDecomposedHiraganasAndKatakanas: true);
        $configs = $recipe->buildTransliteratorConfigs();
        
        $this->assertCount(1, $configs);
        $this->assertEquals('hira-kata-composition', $configs[0][0]);
        $this->assertNotEmpty($configs[0][1]);
        $this->assertTrue($configs[0][1]['decompose']);
    }

    // Test complex option configurations
    public function testHyphensDefaultPrecedence(): void
    {
        $recipe = new TransliterationRecipe(replaceHyphens: true);
        $configs = $recipe->buildTransliteratorConfigs();
        
        $this->assertCount(1, $configs);
        $this->assertEquals('hyphens', $configs[0][0]);
        $this->assertNotEmpty($configs[0][1]);
        $this->assertEquals(
            ['jisx0208_90_windows', 'jisx0201'],
            $configs[0][1]['precedence']
        );
    }

    public function testHyphensCustomPrecedence(): void
    {
        $customPrecedence = ['jisx0201', 'ascii'];
        $recipe = new TransliterationRecipe(replaceHyphens: $customPrecedence);
        $configs = $recipe->buildTransliteratorConfigs();
        
        $config = $configs[0];
        $this->assertEquals($customPrecedence, $config[1]['precedence']);
    }

    public function testToFullwidthBasic(): void
    {
        $recipe = new TransliterationRecipe(toFullwidth: true);
        $configs = $recipe->buildTransliteratorConfigs();
        
        $this->assertCount(1, $configs);
        $this->assertEquals('jisx0201-and-alike', $configs[0][0]);
        $options = $configs[0][1];
        $this->assertNotEmpty($options);
        $this->assertFalse($options['fullwidthToHalfwidth']);
        $this->assertFalse($options['u005c_as_yen_sign']);
    }

    public function testToFullwidthYenSign(): void
    {
        $recipe = new TransliterationRecipe(toFullwidth: 'u005c-as-yen-sign');
        $configs = $recipe->buildTransliteratorConfigs();
        
        $config = $configs[0];
        $this->assertTrue($config[1]['u005c_as_yen_sign']);
    }

    public function testToHalfwidthBasic(): void
    {
        $recipe = new TransliterationRecipe(toHalfwidth: true);
        $configs = $recipe->buildTransliteratorConfigs();
        
        $config = $configs[0];
        $options = $config[1];
        $this->assertTrue($options['fullwidthToHalfwidth']);
        $this->assertTrue($options['convertGL']);
        $this->assertFalse($options['convertGR']);
    }

    public function testToHalfwidthHankakuKana(): void
    {
        $recipe = new TransliterationRecipe(toHalfwidth: 'hankaku-kana');
        $configs = $recipe->buildTransliteratorConfigs();
        
        $config = $configs[0];
        $this->assertTrue($config[1]['convertGR']);
    }

    public function testRemoveIvsSvsBasic(): void
    {
        $recipe = new TransliterationRecipe(removeIvsSvs: true);
        $configs = $recipe->buildTransliteratorConfigs();
        
        // Should have two ivs-svs-base configs
        $ivsSvsConfigs = array_filter($configs, fn($c) => $c[0] === 'ivs-svs-base');
        $this->assertCount(2, $ivsSvsConfigs);
        
        // Check modes
        $modes = array_map(fn($c) => $c[1]['mode'] ?? null, $ivsSvsConfigs);
        $this->assertContains('ivs-or-svs', $modes);
        $this->assertContains('base', $modes);
        
        // Check drop_selectors_altogether is false for basic mode
        foreach ($ivsSvsConfigs as $config) {
            if ($config[1]['mode'] === 'base') {
                $this->assertFalse($config[1]['drop_selectors_altogether']);
            }
        }
    }

    public function testRemoveIvsSvsDropAll(): void
    {
        $recipe = new TransliterationRecipe(removeIvsSvs: 'drop-all-selectors');
        $configs = $recipe->buildTransliteratorConfigs();
        
        // Find base mode config
        foreach ($configs as $config) {
            if ($config[0] === 'ivs-svs-base' && 
                $config[1]['mode'] === 'base') {
                $this->assertTrue($config[1]['drop_selectors_altogether']);
            }
        }
    }

    public function testCharsetConfiguration(): void
    {
        $recipe = new TransliterationRecipe(
            kanjiOldNew: true,
            charset: 'unijis_90'
        );
        $configs = $recipe->buildTransliteratorConfigs();
        
        // Find the ivs-svs-base config with mode "base" which should have charset
        foreach ($configs as $config) {
            if ($config[0] === 'ivs-svs-base' && 
                $config[1]['mode'] === 'base') {
                $this->assertEquals('unijis_90', $config[1]['charset']);
            }
        }
    }

    // Test transliterator ordering
    public function testCircledOrSquaredAndCombinedOrder(): void
    {
        $recipe = new TransliterationRecipe(
            replaceCircledOrSquaredCharacters: true,
            replaceCombinedCharacters: true
        );
        $configs = $recipe->buildTransliteratorConfigs();
        
        $configNames = array_map(fn($c) => $c[0], $configs);
        
        // Both should be present
        $this->assertContains('circled-or-squared', $configNames);
        $this->assertContains('combined', $configNames);
        
        // Verify the order
        $circledPos = array_search('circled-or-squared', $configNames);
        $combinedPos = array_search('combined', $configNames);
        $this->assertLessThan($circledPos, $combinedPos); // actually checking if $combinedPos < $circledPos
    }

    public function testComprehensiveOrdering(): void
    {
        $recipe = new TransliterationRecipe(
            kanjiOldNew: true,
            replaceSuspiciousHyphensToProlongedSoundMarks: true,
            replaceSpaces: true,
            combineDecomposedHiraganasAndKatakanas: true,
            toHalfwidth: true
        );
        
        $configs = $recipe->buildTransliteratorConfigs();
        $configNames = array_map(fn($c) => $c[0], $configs);
        
        // Verify some key orderings
        // hira-kata-composition should be early (head insertion)
        $this->assertContains('hira-kata-composition', $configNames);
        
        // jisx0201-and-alike should be at the end (tail insertion)
        $this->assertEquals('jisx0201-and-alike', end($configNames));
        
        // All should be present
        $this->assertContains('spaces', $configNames);
        $this->assertContains('prolonged-sound-marks', $configNames);
        $this->assertContains('kanji-old-new', $configNames);
    }

    // Test mutually exclusive options
    public function testFullwidthHalfwidthMutualExclusion(): void
    {
        $recipe = new TransliterationRecipe(
            toFullwidth: true,
            toHalfwidth: true
        );
        
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('mutually exclusive');
        $recipe->buildTransliteratorConfigs();
    }

    // Test comprehensive recipe configurations
    public function testAllTransliteratorsEnabled(): void
    {
        $recipe = new TransliterationRecipe(
            combineDecomposedHiraganasAndKatakanas: true,
            kanjiOldNew: true,
            removeIvsSvs: 'drop-all-selectors',
            replaceHyphens: true,
            replaceIdeographicAnnotations: true,
            replaceSuspiciousHyphensToProlongedSoundMarks: true,
            replaceRadicals: true,
            replaceSpaces: true,
            replaceCircledOrSquaredCharacters: true,
            replaceCombinedCharacters: true,
            replaceMathematicalAlphanumerics: true,
            toHalfwidth: 'hankaku-kana',
            charset: 'unijis_90'
        );
        
        $configs = $recipe->buildTransliteratorConfigs();
        $configNames = array_map(fn($c) => $c[0], $configs);
        
        // Verify all expected transliterators are present
        $expectedTransliterators = [
            'ivs-svs-base',  // appears twice
            'kanji-old-new',
            'prolonged-sound-marks',
            'circled-or-squared',
            'combined',
            'ideographic-annotations',
            'radicals',
            'spaces',
            'hyphens',
            'mathematical-alphanumerics',
            'hira-kata-composition',
            'jisx0201-and-alike'
        ];
        
        foreach ($expectedTransliterators as $expected) {
            $this->assertContains($expected, $configNames);
        }
        
        // Verify specific configurations
        $hyphensConfig = array_values(array_filter($configs, fn($c) => $c[0] === 'hyphens'))[0];
        $this->assertEquals(
            ['jisx0208_90_windows', 'jisx0201'],
            $hyphensConfig[1]['precedence']
        );
        
        $jisxConfig = array_values(array_filter($configs, fn($c) => $c[0] === 'jisx0201-and-alike'))[0];
        $this->assertTrue($jisxConfig[1]['convertGR']);
        
        // Count ivs-svs-base occurrences
        $ivsSvsCount = count(array_filter($configs, fn($c) => $c[0] === 'ivs-svs-base'));
        $this->assertEquals(2, $ivsSvsCount);
    }

    // Test functional integration with actual transliteration
    public function testBasicTransliteration(): void
    {
        $recipe = new TransliterationRecipe(
            replaceCircledOrSquaredCharacters: true,
            replaceCombinedCharacters: true,
            replaceSpaces: true,
            replaceMathematicalAlphanumerics: true
        );
        
        $transliterator = Yosina::makeTransliterator($recipe);
        
        // Test mixed content
        $testCases = [
            ['①', '(1)'],  // Circled number
            ['⑴', '(1)'],  // Parenthesized number (combined)
            ['𝐇𝐞𝐥𝐥𝐨', 'Hello'],  // Mathematical alphanumerics
            ['　', ' '],  // Full-width space
        ];
        
        foreach ($testCases as [$input, $expected]) {
            $result = $transliterator($input);
            $this->assertEquals($expected, $result);
        }
    }
    
    public function testExcludeEmojisFunctional(): void
    {
        $recipe = new TransliterationRecipe(
            replaceCircledOrSquaredCharacters: 'exclude-emojis'
        );
        
        $transliterator = Yosina::makeTransliterator($recipe);
        
        // Regular circled characters should still work
        $this->assertEquals('(1)', $transliterator('①'));
        $this->assertEquals('(A)', $transliterator('Ⓐ'));
        
        // Non-emoji squared letters should still be processed
        $this->assertEquals('[A]', $transliterator('🅰'));
        
        // Emoji characters should not be processed
        $this->assertEquals('🆘', $transliterator('🆘'));
    }
}