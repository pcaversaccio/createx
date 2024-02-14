/* eslint-disable @typescript-eslint/no-var-requires */
const eslint = require("@eslint/js");
const tseslint = require("typescript-eslint");
const next = require("@next/eslint-plugin-next");
const react = require("eslint-plugin-react");
const hooks = require("eslint-plugin-react-hooks");
const eslintConfigPrettier = require("eslint-config-prettier");
/* eslint-enable @typescript-eslint/no-var-requires */

module.exports = tseslint.config(
  {
    files: ["**/*.{js,ts,tsx}"],
    extends: [
      eslint.configs.recommended,
      ...tseslint.configs.recommended,
      ...tseslint.configs.stylistic,
      eslintConfigPrettier,
    ],
    plugins: {
      "@typescript-eslint": tseslint.plugin,
      "@next/next": next,
      "react": react,
      "react-hooks": hooks,
    },
    rules: {
      ...next.configs.recommended.rules,
      ...react.configs["jsx-runtime"].rules,
      ...hooks.configs.recommended.rules,
    },
  },
  {
    ignores: ["node_modules/**", ".next/**", "next-env.d.ts", "dist/**"],
  },
);
