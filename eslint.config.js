/* eslint-disable @typescript-eslint/no-require-imports */
const eslint = require("@eslint/js");
const tseslint = require("typescript-eslint");
const eslintConfigPrettier = require("eslint-config-prettier");
const globals = require("globals");
const { defineConfig } = require("eslint/config");
/* eslint-enable @typescript-eslint/no-require-imports */

module.exports = defineConfig(
  {
    files: ["**/*.{js,ts}"],
    extends: [
      eslint.configs.recommended,
      ...tseslint.configs.recommended,
      ...tseslint.configs.stylistic,
      eslintConfigPrettier,
    ],
    plugins: {
      "@typescript-eslint": tseslint.plugin,
    },
    languageOptions: {
      ecmaVersion: "latest",
      parser: tseslint.parser,
      globals: {
        ...globals.node,
      },
      parserOptions: {
        project: true,
        tsconfigRootDir: __dirname,
      },
    },
  },
  {
    ignores: [
      "node_modules/**",
      "pnpm-lock.yaml",
      "interface/**",
      "lib/**",
      "cache/**",
      "typechain-types/**",
      "artifacts/**",
      "forge-artifacts/**",
      "coverage/**",
      "bin/**",
      "out/**",
    ],
  },
);
