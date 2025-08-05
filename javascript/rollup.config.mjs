import { globSync } from 'glob';
import path from 'node:path';
import typescript from '@rollup/plugin-typescript';
import terser from '@rollup/plugin-terser';

export default {
  input: {
    index: "src/index.ts",
    intrinsics: "src/intrinsics.ts",
    recipes: "src/recipes.ts",
    ...Object.fromEntries(
      globSync("src/transliterators/*.ts").map(
        (p) => [
          path.relative('src', p).slice(0, -path.extname(p).length),
          p,
        ]
      )
    ),
  },
  output: {
    dir: "bundle",
    format: "es",
    interop: "auto",
    sourcemap: true,
  },
  plugins: [
    typescript({
      compilerOptions: {
        outDir: "./bundle",
        declaration: false,
      }
    }),
    terser(),
  ],
};
