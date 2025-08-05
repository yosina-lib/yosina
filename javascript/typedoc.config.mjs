import { globSync } from 'glob';

export default {
  "entryPoints": [
    "./src/chars.ts",
    "./src/index.ts",
    "./src/intrinsics.ts",
    "./src/recipes.ts",
    "./src/types.ts",
    ...globSync('./src/transliterators/*.ts'),
  ],
  "out": "./docs",
  "plugin": [
  ]
};
