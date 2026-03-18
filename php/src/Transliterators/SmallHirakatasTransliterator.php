<?php

declare(strict_types=1);

namespace Yosina\Transliterators;

use Yosina\Char;
use Yosina\TransliteratorInterface;

/**
 * Replaces small hiragana/katakana with their ordinary-sized equivalents.
 */
class SmallHirakatasTransliterator implements TransliteratorInterface
{
    private const MAPPINGS = [
        'ぁ' => 'あ',
        'ぃ' => 'い',
        'ぅ' => 'う',
        'ぇ' => 'え',
        'ぉ' => 'お',
        'っ' => 'つ',
        'ゃ' => 'や',
        'ゅ' => 'ゆ',
        'ょ' => 'よ',
        'ゎ' => 'わ',
        'ゕ' => 'か',
        'ゖ' => 'け',
        'ァ' => 'ア',
        'ィ' => 'イ',
        'ゥ' => 'ウ',
        'ェ' => 'エ',
        'ォ' => 'オ',
        'ッ' => 'ツ',
        'ャ' => 'ヤ',
        'ュ' => 'ユ',
        'ョ' => 'ヨ',
        'ヮ' => 'ワ',
        'ヵ' => 'カ',
        'ヶ' => 'ケ',
        'ㇰ' => 'ク',
        'ㇱ' => 'シ',
        'ㇲ' => 'ス',
        'ㇳ' => 'ト',
        'ㇴ' => 'ヌ',
        'ㇵ' => 'ハ',
        'ㇶ' => 'ヒ',
        'ㇷ' => 'フ',
        'ㇸ' => 'ヘ',
        'ㇹ' => 'ホ',
        'ㇺ' => 'ム',
        'ㇻ' => 'ラ',
        'ㇼ' => 'リ',
        'ㇽ' => 'ル',
        'ㇾ' => 'レ',
        'ㇿ' => 'ロ',
        'ｧ' => 'ｱ',
        'ｨ' => 'ｲ',
        'ｩ' => 'ｳ',
        'ｪ' => 'ｴ',
        'ｫ' => 'ｵ',
        'ｬ' => 'ﾔ',
        'ｭ' => 'ﾕ',
        'ｮ' => 'ﾖ',
        'ｯ' => 'ﾂ',
        '𛄲' => 'こ',
        '𛅐' => 'ゐ',
        '𛅑' => 'ゑ',
        '𛅒' => 'を',
        '𛅕' => 'コ',
        '𛅤' => 'ヰ',
        '𛅥' => 'ヱ',
        '𛅦' => 'ヲ',
        '𛅧' => 'ン',
    ];

    /**
     * @param array<string, mixed> $options
     */
    public function __construct(/* @phpstan-ignore constructor.unusedParameter */ array $options = []) {}

    /**
     * @param iterable<Char> $inputChars
     * @return iterable<Char>
     */
    public function __invoke(iterable $inputChars): iterable
    {
        $offset = 0;
        foreach ($inputChars as $char) {
            $replacement = self::MAPPINGS[$char->c] ?? null;
            if ($replacement !== null) {
                yield new Char($replacement, $offset, $char);
                $offset += strlen($replacement);
            } else {
                yield $char->withOffset($offset);
                $offset += strlen($char->c);
            }
        }
    }
}
