import prettier from "eslint-plugin-prettier";
import eslintConfigPrettier from "eslint-config-prettier";
import globals from "globals";
import path from "node:path";
import { fileURLToPath } from "node:url";
import js from "@eslint/js";
import pluginVue from "eslint-plugin-vue";
import ts from "typescript-eslint";
import { FlatCompat } from "@eslint/eslintrc";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const compat = new FlatCompat({
    baseDirectory: __dirname,
    recommendedConfig: js.configs.recommended,
    allConfig: js.configs.all,
});

export default [
    ...compat.extends("eslint:recommended", "eslint-config-prettier"),
    ...ts.configs.recommended,
    ...pluginVue.configs["flat/recommended"],
    eslintConfigPrettier,
    {
        plugins: {
            prettier,
        },
        languageOptions: {
            globals: {
                ...globals.browser,
                ...globals.jquery,
            },
        },
        rules: {
            "prettier/prettier": ["error"],
        },
    },
];
