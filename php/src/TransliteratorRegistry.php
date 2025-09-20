<?php

declare(strict_types=1);

namespace Yosina;

use Yosina\Transliterators\SpacesTransliterator;
use Yosina\Transliterators\RadicalsTransliterator;
use Yosina\Transliterators\MathematicalAlphanumericsTransliterator;
use Yosina\Transliterators\IdeographicAnnotationsTransliterator;
use Yosina\Transliterators\KanjiOldNewTransliterator;
use Yosina\Transliterators\HyphensTransliterator;
use Yosina\Transliterators\IvsSvsBaseTransliterator;
use Yosina\Transliterators\HiraKataCompositionTransliterator;
use Yosina\Transliterators\HiraKataTransliterator;
use Yosina\Transliterators\Jisx0201AndAlikeTransliterator;
use Yosina\Transliterators\ProlongedSoundMarksTransliterator;
use Yosina\Transliterators\CircledOrSquaredTransliterator;
use Yosina\Transliterators\CombinedTransliterator;
use Yosina\Transliterators\RomanNumeralsTransliterator;
use Yosina\Transliterators\JapaneseIterationMarksTransliterator;

class TransliteratorRegistry
{
    public const SUPPORTED_TRANSLITERATORS = [
        'spaces',
        'radicals',
        'mathematical-alphanumerics',
        'ideographic-annotations',
        'kanji-old-new',
        'hyphens',
        'ivs-svs-base',
        'hira-kata-composition',
        'hira-kata',
        'jisx0201-and-alike',
        'prolonged-sound-marks',
        'circled-or-squared',
        'combined',
        'roman-numerals',
        'japanese-iteration-marks',
    ];

    /** @var array<string, class-string<TransliteratorInterface>> */
    private static array $factories = [
        'spaces' => SpacesTransliterator::class,
        'radicals' => RadicalsTransliterator::class,
        'mathematical-alphanumerics' => MathematicalAlphanumericsTransliterator::class,
        'ideographic-annotations' => IdeographicAnnotationsTransliterator::class,
        'kanji-old-new' => KanjiOldNewTransliterator::class,
        'hyphens' => HyphensTransliterator::class,
        'ivs-svs-base' => IvsSvsBaseTransliterator::class,
        'hira-kata-composition' => HiraKataCompositionTransliterator::class,
        'hira-kata' => HiraKataTransliterator::class,
        'jisx0201-and-alike' => Jisx0201AndAlikeTransliterator::class,
        'prolonged-sound-marks' => ProlongedSoundMarksTransliterator::class,
        'circled-or-squared' => CircledOrSquaredTransliterator::class,
        'combined' => CombinedTransliterator::class,
        'roman-numerals' => RomanNumeralsTransliterator::class,
        'japanese-iteration-marks' => JapaneseIterationMarksTransliterator::class,
    ];

    public static function getTransliteratorFactory(string $name): TransliteratorFactoryInterface
    {
        if (!in_array($name, self::SUPPORTED_TRANSLITERATORS, true)) {
            throw new \InvalidArgumentException("Transliterator not found: {$name}");
        }

        $className = self::$factories[$name] ?? null;
        if (!$className) {
            throw new \InvalidArgumentException("Transliterator implementation not found: {$name}");
        }

        return new class ($className) implements TransliteratorFactoryInterface {
            public function __construct(private string $className) {}

            /**
             * @param array<string, mixed> $options
             */
            public function __invoke(array $options): TransliteratorInterface
            {
                /** @var TransliteratorInterface */
                return new ($this->className)($options);
            }
        };
    }
}
