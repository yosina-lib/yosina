<?php

declare(strict_types=1);

namespace Yosina;

/**
 * Main Yosina API for Japanese text transliteration.
 */
class Yosina
{
    /**
     * Create a chained transliterator from configuration array.
     *
     * @param array<array{string, array<string, mixed>}|string> $transliteratorConfigs
     */
    public static function makeChainedTransliterator(array $transliteratorConfigs): TransliteratorInterface
    {
        $transliterators = [];

        foreach ($transliteratorConfigs as $config) {
            if (is_string($config)) {
                $factory = TransliteratorRegistry::getTransliteratorFactory($config);
                $transliterators[] = $factory([]);
            } elseif (is_array($config) && count($config) === 2) {
                [$name, $options] = $config;
                $factory = TransliteratorRegistry::getTransliteratorFactory($name);
                $transliterators[] = $factory($options);
            } else {
                throw new \InvalidArgumentException('Invalid transliterator configuration');
            }
        }

        return new ChainedTransliterator($transliterators);
    }

    /**
     * Build transliterator configurations from a recipe.
     * @return array<int, array{0: string, 1: array<string, mixed>}>
     */
    public static function buildTransliteratorConfigsFromRecipe(TransliterationRecipe $recipe): array
    {
        return $recipe->buildTransliteratorConfigs();
    }

    /**
     * Create a string-to-string transliterator from configuration or recipe.
     *
     * @param array<array{string, array<string, mixed>}|string>|TransliterationRecipe $configsOrRecipe
     */
    public static function makeTransliterator(array|TransliterationRecipe $configsOrRecipe): callable
    {
        if ($configsOrRecipe instanceof TransliterationRecipe) {
            $configs = self::buildTransliteratorConfigsFromRecipe($configsOrRecipe);
        } else {
            $configs = $configsOrRecipe;
        }

        $transliterator = self::makeChainedTransliterator($configs);

        return function (string $input) use ($transliterator): string {
            $chars = Chars::buildCharArray($input);
            $transliteratedChars = $transliterator($chars);
            return Chars::fromChars($transliteratedChars);
        };
    }
}
