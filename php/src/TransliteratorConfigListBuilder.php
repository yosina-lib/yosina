<?php

declare(strict_types=1);

namespace Yosina;

/**
 * Internal builder for creating lists of transliterator configurations.
 * Follows the same pattern as the Java TransliteratorConfigListBuilder.
 */
class TransliteratorConfigListBuilder
{
    /** @var array<int, array{0: string, 1: array<string, mixed>}> */
    private array $head;

    /** @var array<int, array{0: string, 1: array<string, mixed>}> */
    private array $tail;

    /**
     * @param array<int, array{0: string, 1: array<string, mixed>}> $head
     * @param array<int, array{0: string, 1: array<string, mixed>}> $tail
     */
    public function __construct(array $head = [], array $tail = [])
    {
        $this->head = $head;
        $this->tail = $tail;
    }

    /**
     * @param array{0: string, 1: array<string, mixed>} $config
     */
    public function insertHead(array $config, bool $forceReplace): self
    {
        $newHead = $this->head;
        $existingIndex = $this->findConfigIndex($newHead, $config[0]);

        if ($existingIndex >= 0) {
            if ($forceReplace) {
                $newHead[$existingIndex] = $config;
            }
        } else {
            array_unshift($newHead, $config);
        }

        return new self($newHead, $this->tail);
    }

    /**
     * @param array{0: string, 1: array<string, mixed>} $config
     */
    public function insertMiddle(array $config, bool $forceReplace): self
    {
        $newTail = $this->tail;
        $existingIndex = $this->findConfigIndex($newTail, $config[0]);

        if ($existingIndex >= 0) {
            if ($forceReplace) {
                $newTail[$existingIndex] = $config;
            }
        } else {
            array_unshift($newTail, $config);
        }

        return new self($this->head, $newTail);
    }

    /**
     * @param array{0: string, 1: array<string, mixed>} $config
     */
    public function insertTail(array $config, bool $forceReplace): self
    {
        $newTail = $this->tail;
        $existingIndex = $this->findConfigIndex($newTail, $config[0]);

        if ($existingIndex >= 0) {
            if ($forceReplace) {
                $newTail[$existingIndex] = $config;
            }
        } else {
            $newTail[] = $config;
        }

        return new self($this->head, $newTail);
    }

    /**
     * @param array<int, array{0: string, 1: array<string, mixed>}> $configs
     */
    private function findConfigIndex(array $configs, string $name): int
    {
        foreach ($configs as $i => $config) {
            if ($config[0] === $name) {
                return $i;
            }
        }
        return -1;
    }

    /**
     * @return array<int, array{0: string, 1: array<string, mixed>}>
     */
    public function build(): array
    {
        return array_merge($this->head, $this->tail);
    }
}
