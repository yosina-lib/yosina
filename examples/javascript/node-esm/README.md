# Yosina Node.js ES Modules Examples

This directory contains examples demonstrating how to use Yosina in Node.js applications using ES Modules (ESM).

## Prerequisites

- Node.js 16 or later (with ES Modules support)
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

### ES Modules Import Style

```javascript
import { makeTransliterator } from '@yosina-lib/yosina';

const transliterator = makeTransliterator('simple');
const result = transliterator('全角　スペース');
console.log(result); // "全角 スペース"
```

### Configuration-based approach with top-level await

```javascript
import { makeTransliterator } from '@yosina-lib/yosina';

const config = [
  { id: 'spaces' },
  { id: 'hyphens', options: { unified: true } }
];
const transliterator = await makeTransliterator(config);
```

## Development

### TypeScript Configuration

The project uses TypeScript with the following key settings:
- Target: ES2020
- Module: ES2022 (for ES modules)
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
node-esm/
├── src/                    # TypeScript source files
│   ├── basic_usage.ts
│   ├── advanced_usage.ts
│   └── config_based_usage.ts
├── dist/                   # Compiled JavaScript files
├── package.json           # Node.js project configuration (type: "module")
├── package-lock.json      # Locked dependencies
└── tsconfig.json          # TypeScript configuration
```

## ES Modules Features

This example leverages modern ES Modules features:

- **Native `import`/`export`** - Modern module syntax
- **Top-level `await`** - Use await at the module level
- **`.js` extensions** - Required for ES modules
- **URL imports** - Support for URL-based module specifiers

## Common Use Cases

- **Modern Node.js Applications**: Build with the latest module system
- **Serverless Functions**: Deploy to platforms supporting ES modules
- **Microservices**: Create lightweight services with modern syntax
- **CLI Tools**: Build command-line tools with ES modules
- **API Services**: Modern REST or GraphQL services

## Differences from CommonJS

This example uses ES Modules which offers several advantages:

- Uses `import`/`export` instead of `require`/`module.exports`
- Supports top-level `await`
- Static module structure enables better optimization
- Native browser compatibility (same syntax)
- Asynchronous module loading

## Troubleshooting

### Build Errors

If TypeScript compilation fails:
1. Ensure Node.js 16+ is installed: `node --version`
2. Delete `node_modules` and reinstall: `rm -rf node_modules && npm install`
3. Check that the local Yosina package exists at `../../../javascript`

### Module Resolution Errors

ES Modules require explicit file extensions:
1. Imports must include `.js` extension (even for TypeScript files)
2. The `"type": "module"` must be set in package.json
3. Node.js must be run with ES module support (default in v16+)

### Runtime Errors

If you encounter module not found errors:
1. Ensure you've built the project: `npm run build`
2. Check that file extensions are included in imports
3. Verify `@yosina-lib/yosina` is properly installed

### Type Errors

For TypeScript type issues:
1. The local Yosina package should include type definitions
2. Check `tsconfig.json` for proper ES module configuration
3. Ensure your IDE supports TypeScript with ES modules

## Further Reading

- [Yosina JavaScript README](../../../javascript/README.md)
- [Main Yosina README](../../../README.md)
- [Node.js ES Modules](https://nodejs.org/api/esm.html)
- [TypeScript ES Modules](https://www.typescriptlang.org/docs/handbook/esm-node.html)