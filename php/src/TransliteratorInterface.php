<?php

declare(strict_types=1);

namespace Yosina;

interface TransliteratorInterface
{
    /**
     * @param iterable<Char> $inputChars
     * @return iterable<Char>
     */
    public function __invoke(iterable $inputChars): iterable;
}
