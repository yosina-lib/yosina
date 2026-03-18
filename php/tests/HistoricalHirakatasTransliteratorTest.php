<?php

declare(strict_types=1);

use PHPUnit\Framework\TestCase;
use Yosina\Chars;
use Yosina\TransliteratorInterface;
use Yosina\TransliteratorRegistry;
use Yosina\Transliterators\HistoricalHirakatasTransliterator;

class HistoricalHirakatasTransliteratorTest extends TestCase
{
    private function processString(TransliteratorInterface $transliterator, string $input): string
    {
        $chars = Chars::buildCharArray($input);
        return Chars::fromChars($transliterator($chars));
    }

    public function testSimpleHiraganaDefault(): void
    {
        $transliterator = new HistoricalHirakatasTransliterator([]);
        $this->assertEquals('いえ', $this->processString($transliterator, 'ゐゑ'));
    }

    public function testPassthrough(): void
    {
        $transliterator = new HistoricalHirakatasTransliterator([]);
        $this->assertEquals('あいう', $this->processString($transliterator, 'あいう'));
    }

    public function testMixedInput(): void
    {
        $transliterator = new HistoricalHirakatasTransliterator([]);
        $this->assertEquals('あいいえう', $this->processString($transliterator, 'あゐいゑう'));
    }

    public function testDecomposeHiragana(): void
    {
        $transliterator = new HistoricalHirakatasTransliterator([
            'hiraganas' => 'decompose',
            'katakanas' => 'skip',
        ]);
        $this->assertEquals('うぃうぇ', $this->processString($transliterator, 'ゐゑ'));
    }

    public function testSkipHiragana(): void
    {
        $transliterator = new HistoricalHirakatasTransliterator([
            'hiraganas' => 'skip',
            'katakanas' => 'skip',
        ]);
        $this->assertEquals('ゐゑ', $this->processString($transliterator, 'ゐゑ'));
    }

    public function testSimpleKatakanaDefault(): void
    {
        $transliterator = new HistoricalHirakatasTransliterator([]);
        $this->assertEquals('イエ', $this->processString($transliterator, 'ヰヱ'));
    }

    public function testDecomposeKatakana(): void
    {
        $transliterator = new HistoricalHirakatasTransliterator([
            'hiraganas' => 'skip',
            'katakanas' => 'decompose',
        ]);
        $this->assertEquals('ウィウェ', $this->processString($transliterator, 'ヰヱ'));
    }

    public function testVoicedKatakanaDecompose(): void
    {
        $transliterator = new HistoricalHirakatasTransliterator([
            'hiraganas' => 'skip',
            'katakanas' => 'skip',
            'voicedKatakanas' => 'decompose',
        ]);
        $this->assertEquals('ヴァヴィヴェヴォ', $this->processString($transliterator, 'ヷヸヹヺ'));
    }

    public function testVoicedKatakanaSkipDefault(): void
    {
        $transliterator = new HistoricalHirakatasTransliterator([
            'hiraganas' => 'skip',
            'katakanas' => 'skip',
        ]);
        $this->assertEquals('ヷヸヹヺ', $this->processString($transliterator, 'ヷヸヹヺ'));
    }

    public function testAllDecompose(): void
    {
        $transliterator = new HistoricalHirakatasTransliterator([
            'hiraganas' => 'decompose',
            'katakanas' => 'decompose',
            'voicedKatakanas' => 'decompose',
        ]);
        $this->assertEquals(
            'うぃうぇウィウェヴァヴィヴェヴォ',
            $this->processString($transliterator, 'ゐゑヰヱヷヸヹヺ'),
        );
    }

    public function testAllSkip(): void
    {
        $transliterator = new HistoricalHirakatasTransliterator([
            'hiraganas' => 'skip',
            'katakanas' => 'skip',
            'voicedKatakanas' => 'skip',
        ]);
        $this->assertEquals('ゐゑヰヱヷヸヹヺ', $this->processString($transliterator, 'ゐゑヰヱヷヸヹヺ'));
    }

    public function testDecomposedVoicedKatakanaDecompose(): void
    {
        $transliterator = new HistoricalHirakatasTransliterator([
            'hiraganas' => 'skip',
            'katakanas' => 'skip',
            'voicedKatakanas' => 'decompose',
        ]);
        $this->assertEquals("ウ\u{3099}ァウ\u{3099}ィウ\u{3099}ェウ\u{3099}ォ", $this->processString($transliterator, "ワ\u{3099}ヰ\u{3099}ヱ\u{3099}ヲ\u{3099}"));
    }

    public function testDecomposedVoicedKatakanaSkip(): void
    {
        $transliterator = new HistoricalHirakatasTransliterator([
            'hiraganas' => 'skip',
            'katakanas' => 'skip',
            'voicedKatakanas' => 'skip',
        ]);
        $this->assertEquals("ワ\u{3099}ヰ\u{3099}ヱ\u{3099}ヲ\u{3099}", $this->processString($transliterator, "ワ\u{3099}ヰ\u{3099}ヱ\u{3099}ヲ\u{3099}"));
    }

    public function testDecomposedVoicedNotSplitFromBase(): void
    {
        // ヰ+゙ must be treated as ヸ (voiced), not as ヰ (katakana) + separate ゙
        $transliterator = new HistoricalHirakatasTransliterator([
            'hiraganas' => 'skip',
            'katakanas' => 'simple',
            'voicedKatakanas' => 'skip',
        ]);
        $this->assertEquals("ヰ\u{3099}", $this->processString($transliterator, "ヰ\u{3099}"));
    }

    public function testDecomposedVoicedWithDecompose(): void
    {
        // ヰ+゙ = ヸ, should produce ヴィ
        $transliterator = new HistoricalHirakatasTransliterator([
            'hiraganas' => 'skip',
            'katakanas' => 'skip',
            'voicedKatakanas' => 'decompose',
        ]);
        $this->assertEquals("ウ\u{3099}ィ", $this->processString($transliterator, "ヰ\u{3099}"));
    }

    public function testEmptyInput(): void
    {
        $transliterator = new HistoricalHirakatasTransliterator([]);
        $this->assertEquals('', $this->processString($transliterator, ''));
    }

    public function testRegistryIntegration(): void
    {
        $factory = TransliteratorRegistry::getTransliteratorFactory('historical-hirakatas');
        $transliterator = $factory([]);
        $this->assertEquals('いえ', $this->processString($transliterator, 'ゐゑ'));
    }
}
