# Yosina PHP Examples

This directory contains example applications demonstrating various use cases for the Yosina PHP library, structured as a proper Composer project.

## Prerequisites

Make sure you have PHP 8.1+ and Composer installed:

```bash
# Check PHP version
php --version

# Install Composer if you haven't already
# See: https://getcomposer.org/download/
```

## Setup

### Initialize the project:

```bash
# From this directory (examples/php)
composer install

# This will install the Yosina library as a dependency
```

### Alternative setup with local development version:

The composer.json is already configured to use the local development version of Yosina from `../../php`. If you want to use a published version instead:

```bash
# Edit composer.json to remove the repositories section and change:
# "yosina/yosina": "dev-main"
# to:
# "yosina/yosina": "^1.0"
```

## Running the Examples

### Using Composer scripts (Recommended)

```bash
# Run individual examples
composer example:basic
composer example:config
composer example:advanced

# Run all examples at once
composer examples
```

### Using PHP directly

```bash
# From this directory (examples/php)

# Run basic usage example
php src/basic_usage.php

# Run configuration-based usage example
php src/config_based_usage.php

# Run advanced usage example
php src/advanced_usage.php
```

## Examples

### 1. Basic Usage (`src/basic_usage.php`)

Demonstrates the fundamental usage patterns:
- Using `TransliterationRecipe` for common transformations
- Simple kanji old-to-new conversion
- Comprehensive text normalization

```bash
composer example:basic
```

### 2. Configuration-based Usage (`src/config_based_usage.php`)

Shows how to use direct transliterator configurations:
- Creating transliterators with specific configs
- Individual transliterator examples
- Fine-grained control over transformations

```bash
composer example:config
```

### 3. Advanced Usage (`src/advanced_usage.php`)

Demonstrates complex real-world scenarios:
- Web scraping text normalization
- Document standardization workflows
- Search index preparation
- Custom processing pipelines
- Unicode edge case handling

```bash
composer example:advanced
```

## Key Concepts Demonstrated

### Recipe-based Approach (Recommended)

```php
use Yosina\TransliterationRecipe;
use Yosina\Yosina;

$recipe = new TransliterationRecipe(
    kanjiOldNew: true,
    replaceSpaces: true,
    toFullwidth: true
);

$transliterator = Yosina::makeTransliterator($recipe);
$result = $transliterator("some text");
```

### Configuration-based Approach

```php
use Yosina\Yosina;

$configs = [
    ["kanji-old-new", []],
    ["spaces", []],
    ["jisx0201-and-alike", ["to" => "fullwidth"]]
];

$transliterator = Yosina::makeTransliterator($configs);
$result = $transliterator("some text");
```

## Development

### Code Quality

```bash
# Format code (if you have PHP-CS-Fixer)
vendor/bin/php-cs-fixer fix

# Run PHPStan for static analysis (if configured)
vendor/bin/phpstan analyse

# Check code with any linting tools you've configured
composer check-code
```

## Common Use Cases

1. **Web Content Normalization**: Clean up scraped Japanese text
2. **Document Processing**: Standardize text formatting
3. **Search Index Preparation**: Normalize text for search engines
4. **Data Cleaning**: Remove inconsistencies in text data
5. **Typography**: Ensure consistent character usage

## Troubleshooting

If you encounter issues:

1. **Autoloader errors**: Make sure you've run `composer install` in this directory
2. **Class not found**: Ensure the autoloader is properly included
3. **Path issues**: Make sure you're running from the correct directory

### Common solutions:

```bash
# Reinstall dependencies
composer install --no-cache

# Dump autoload
composer dump-autoload

# Check installation
php -r "require_once 'vendor/autoload.php'; use Yosina\Yosina; echo 'Success!';"
```

## Further Reading

- [Yosina PHP README](../../php/README.md)
- [Main Project README](../../README.md)
- [Yosina Specification](https://github.com/yosina-lib/yosina-spec)