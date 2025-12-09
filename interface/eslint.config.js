/* eslint-disable @typescript-eslint/no-require-imports */
const eslint = require("@eslint/js");
const tseslint = require("typescript-eslint");
const next = require("@next/eslint-plugin-next");
const react = require("eslint-plugin-react");
const reactHooks = require("eslint-plugin-react-hooks");
const eslintConfigPrettier = require("eslint-config-prettier");
const globals = require("globals");
const { defineConfig } = require("eslint/config");
/* eslint-enable @typescript-eslint/no-require-imports */

module.exports = defineConfig(
  {
    files: ["**/*.{js,mjs,ts,tsx}"],
    extends: [
      eslint.configs.recommended,
      ...tseslint.configs.recommended,
      ...tseslint.configs.stylistic,
      eslintConfigPrettier,
    ],
    plugins: {
      "@typescript-eslint": tseslint.plugin,
      "@next/next": next,
      react: react,
      "react-hooks": reactHooks,
    },
    rules: {
      ...next.configs.recommended.rules,
      ...react.configs["jsx-runtime"].rules,
      ...reactHooks.configs.recommended.rules,
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
    ignores: ["node_modules/**", ".next/**", "next-env.d.ts", "dist/**"],
  },
);
