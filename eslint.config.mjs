import globals from "globals";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { FlatCompat } from "@eslint/eslintrc";
import eslintjs from "@eslint/js";
import vueEslintParser from "vue-eslint-parser"; // Import the parser directly

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const compat = new FlatCompat({
    baseDirectory: __dirname,
    recommendedConfig: eslintjs.configs.recommended,
});

export default [
  ...compat.extends(
    "plugin:vue/essential",
    "eslint:recommended"
  ),
  {
    files: ["**/*.{js,mjs,vue}"],
    languageOptions: {
      globals: {
        ...globals.browser,
        ...globals.node,
      },
      ecmaVersion: 2020,
      sourceType: "module",
      // Pass the directly imported parser module
      parser: vueEslintParser,
      parserOptions: {
        ecmaVersion: 2020,
        sourceType: "module",
        // If you need a specific JS parser for the <script> tags within .vue files,
        // you would configure it here under 'parser'. For example:
        // parser: "@babel/eslint-parser",
        // If you use 'vue-eslint-parser' alone, it usually handles the JS parsing
        // internally, but depending on your setup, you might need a secondary parser.
        // For now, let's keep it simple.
      },
    },
    rules: {
      indent: ["error", 2],
      "linebreak-style": ["error", "unix"],
      quotes: ["error", "single"],
      semi: ["error", "always"],
    },
  },
];