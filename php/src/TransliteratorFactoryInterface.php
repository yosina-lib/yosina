<?php

declare(strict_types=1);

namespace Yosina;

interface TransliteratorFactoryInterface
{
    /**
     * @param array<string, mixed> $options
     */
    public function __invoke(array $options): TransliteratorInterface;
}
