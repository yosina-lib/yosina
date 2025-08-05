<?php

declare(strict_types=1);

namespace Yosina;

readonly class Char
{
    public function __construct(
        public string $c,
        public int $offset,
        public ?Char $source = null,
    ) {}
}
