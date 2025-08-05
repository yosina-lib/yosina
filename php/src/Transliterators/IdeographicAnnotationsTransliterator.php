<?php

declare(strict_types=1);

namespace Yosina\Transliterators;

use Yosina\Char;
use Yosina\TransliteratorInterface;

/**
 * Replace ideographic annotation marks used in traditional translation.
 */
class IdeographicAnnotationsTransliterator implements TransliteratorInterface
{
    private const MAPPINGS = [
        '㆒' => '一',
        '㆓' => '二',
        '㆔' => '三',
        '㆕' => '四',
        '㆖' => '上',
        '㆗' => '中',
        '㆘' => '下',
        '㆙' => '甲',
        '㆚' => '乙',
        '㆛' => '丙',
        '㆜' => '丁',
        '㆝' => '天',
        '㆞' => '地',
        '㆟' => '人',
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
