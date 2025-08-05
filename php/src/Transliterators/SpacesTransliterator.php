<?php

declare(strict_types=1);

namespace Yosina\Transliterators;

use Yosina\Char;
use Yosina\TransliteratorInterface;

/**
 * Replace various space characters with plain whitespace.
 */
class SpacesTransliterator implements TransliteratorInterface
{
    private const MAPPINGS = [
        ' ' => " ",
        '᠎' => "",
        ' ' => " ",
        ' ' => " ",
        ' ' => " ",
        ' ' => " ",
        ' ' => " ",
        ' ' => " ",
        ' ' => " ",
        ' ' => " ",
        ' ' => " ",
        ' ' => " ",
        ' ' => " ",
        '​' => " ",
        ' ' => " ",
        ' ' => " ",
        '　' => " ",
        'ㅤ' => " ",
        'ﾠ' => " ",
        '﻿' => "",
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
