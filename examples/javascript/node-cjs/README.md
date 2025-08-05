# Yosina Node.js CommonJS Examples

This directory contains examples demonstrating how to use Yosina in Node.js applications using CommonJS modules.

## Prerequisites

- Node.js 16 or later
- npm (comes with Node.js)

## Setup

Install dependencies:

```bash
npm install
```

For local development, this example is configured to use the local JavaScript implementation via a file reference in package.json.

## Building the Examples

Since the examples are written in TypeScript, they need to be compiled first:

```bash
npm run build
```

This will compile the TypeScript files from `src/` to JavaScript files in `dist/`.

## Running the Examples

After building, run the examples:

```bash
# Run basic usage example
node dist/basic_usage.js

# Run advanced usage example
node dist/advanced_usage.js

# Run config-based usage example
node dist/config_based_usage.js
```

## Examples

1. **basic_usage.ts** - Demonstrates basic transliteration functionality
   - Simple text conversion
   - Using individual transliterators
   - Basic Unicode normalization

2. **advanced_usage.ts** - Shows advanced features
   - Chaining multiple transliterators
   - Custom configuration options
   - Handling complex text transformations

3. **config_based_usage.ts** - Recipe-based approach (recommended)
   - Using predefined recipes
   - Creating custom recipes
   - Batch processing with configurations

## Key Concepts Demonstrated

### CommonJS Import Style

```javascript
const { makeTransliterator } = require('@yosina-lib/yosina');

const transliterator = makeTransliterator('simple');
const result = transliterator('全角　スペース');
console.log(result); // "全角 スペース"
```

### Configuration-based approach

```javascript
const { makeTransliterator } = require('@yosina-lib/yosina');

const config = [
  { id: 'spaces' },
  { id: 'hyphens', options: { unified: true } }
];
const transliterator = makeTransliterator(config);
```

## Development

### TypeScript Configuration

The project uses TypeScript with the following key settings:
- Target: ES2020
- Module: CommonJS
- Strict mode enabled

### Available Scripts

```bash
# Build TypeScript files
npm run build

# Install dependencies
npm install
```

## Project Structure

```
node-cjs/
├── src/                    # TypeScript source files
│   ├── basic_usage.ts
│   ├── advanced_usage.ts
│   └── config_based_usage.ts
├── dist/                   # Compiled JavaScript files
├── package.json           # Node.js project configuration
├── package-lock.json      # Locked dependencies
└── tsconfig.json          # TypeScript configuration
```

## Common Use Cases

- **Server-side Text Processing**: Process user input on the backend
- **Data Pipeline**: Normalize text data in batch processing
- **API Development**: Provide text normalization endpoints
- **Build Tools**: Integrate into build processes for content transformation
- **Database Operations**: Clean data before storage

## Differences from ES Modules

This example uses CommonJS (`require`/`module.exports`) which is the traditional Node.js module system. Key differences:

- Uses `require()` instead of `import`
- Uses `module.exports` instead of `export`
- No top-level `await` support
- Synchronous module loading

## Troubleshooting

### Build Errors

If TypeScript compilation fails:
1. Ensure Node.js 16+ is installed: `node --version`
2. Delete `node_modules` and reinstall: `rm -rf node_modules && npm install`
3. Check that the local Yosina package exists at `../../../javascript`

### Runtime Errors

If you encounter module not found errors:
1. Ensure you've built the project: `npm run build`
2. Run from the project root directory
3. Check that `@yosina-lib/yosina` is properly installed

### Type Errors

For TypeScript type issues:
1. The local Yosina package should include type definitions
2. Check `tsconfig.json` for proper configuration
3. Ensure your IDE has TypeScript support enabled

## Further Reading

- [Yosina JavaScript README](../../../javascript/README.md)
- [Main Yosina README](../../../README.md)
- [Node.js CommonJS Modules](https://nodejs.org/api/modules.html)
- [TypeScript Documentation](https://www.typescriptlang.org/docs/)