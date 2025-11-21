import globals from "globals";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { FlatCompat } from "@eslint/eslintrc";
import eslintjs from "@eslint/js";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const compat = new FlatCompat({
  baseDirectory: __dirname,
  recommendedConfig: eslintjs.configs.recommended,
});

export default [
  {
    ignores: [
      "app/assets/builds/",
      "node_modules/",
      "public/assets/",
      "vendor/",
      "tmp/",
      "log/",
    ],
  },
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
    },
    rules: {
      indent: ["error", 2],
      "linebreak-style": ["error", "unix"],
      quotes: ["error", "single"],
      semi: ["error", "always"],
    },
  },
];