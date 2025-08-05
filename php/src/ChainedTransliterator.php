<?php

declare(strict_types=1);

namespace Yosina;

class ChainedTransliterator implements TransliteratorInterface
{
    /**
     * @param array<TransliteratorInterface> $transliterators
     */
    public function __construct(private array $transliterators)
    {
        if (empty($transliterators)) {
            throw new \InvalidArgumentException('At least one transliterator must be specified');
        }
    }

    /**
     * @param iterable<Char> $inputChars
     * @return iterable<Char>
     */
    public function __invoke(iterable $inputChars): iterable
    {
        $result = $inputChars;
        foreach ($this->transliterators as $transliterator) {
            $result = $transliterator($result);
        }
        return $result;
    }
}
