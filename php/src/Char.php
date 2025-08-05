<?php

declare(strict_types=1);

namespace Yosina;

readonly class Char
{
    public function withOffset(int $offset): self
    {
        return new self($this->c, $offset, $this);
    }

    public function isTransliterated(): bool
    {
        $c = $this;
        for (;;) {
            $s = $c->source;
            if ($s === null) {
                break;
            }
            if ($c->c !== $s->c) {
                return true;
            }
            $c = $s;
        }
        return false;
    }

    public function isSentinel(): bool
    {
        return $this->c === '';
    }

    public function __construct(
        public string $c,
        public int $offset,
        public ?Char $source = null,
    ) {}
}
