/* eslint-disable @typescript-eslint/no-var-requires */
const eslint = require("@eslint/js");
const tseslint = require("typescript-eslint");
const eslintConfigPrettier = require("eslint-config-prettier");
/* eslint-enable @typescript-eslint/no-var-requires */

module.exports = tseslint.config(
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
      parserOptions: {
        project: true,
      },
    },
  },
  {
    ignores: [
      "node_modules/**",
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
