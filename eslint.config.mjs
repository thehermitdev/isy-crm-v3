// eslint.config.mjs
import js from '@eslint/js';
import globals from 'globals';
import tseslint from 'typescript-eslint';
import prettierConfig from 'eslint-config-prettier';

/** @type {import('eslint').Linter.Config[]} */
export default [
  // 1. Global Ignores (Replaces .eslintignore)
  // - "Ignoring Files" section
  {
    ignores: [
      '**/node_modules',
      '**/dist',
      '**/build',
      '**/.open-next',
      '**/coverage',
    ],
  },

  // 2. Base JavaScript Configuration
  // - "Predefined and Shareable Configs"
  js.configs.recommended,
  ...tseslint.configs.recommended, // TypeScript Configuration: We spread the recommended config array from typescript-eslint
  prettierConfig, // Prettier Configuration: Must be last to override other configs and disable conflicting rules

  // 3. Custom Rules & Language Options (The "Law Book")
  {
    languageOptions: {
      ecmaVersion: 2024,
      sourceType: 'module',
      // - "Configuring Language Options"
      globals: {
        ...globals.browser,
        ...globals.node,
        ...globals.es2021,
      },
      // - "Enable Type-Aware Linting"
      parserOptions: {
        projectService: {
          allowDefaultProject: ['eslint.config.mjs'],
        },
        tsconfigRootDir: import.meta.dirname,
      },
    },
    rules: {
      /* --- Pillar 1: Type Safety --- */
      '@typescript-eslint/no-explicit-any': 'error',

      /* --- Pillar 2: Clean Code (Unused Imports/Vars) --- */
      '@typescript-eslint/no-unused-vars': [
        'error',
        {
          argsIgnorePattern: '^_',
          varsIgnorePattern: '^_',
          caughtErrorsIgnorePattern: '^_',
        },
      ],

      /* --- Pillar 3: Naming Convention --- */
      '@typescript-eslint/naming-convention': [
        'error',
        // 1. Interfaces & Type Aliases -> PascalCase
        {
          selector: 'typeLike',
          format: ['PascalCase'],
        },
        // 2. Interfaces should NOT start with "I"
        {
          selector: 'interface',
          format: ['PascalCase'],
          custom: {
            regex: '^I[A-Z]',
            match: false,
          },
        },
        // 3. Variables & Functions -> camelCase, UPPER_CASE (constants), PascalCase (components)
        {
          selector: 'variable',
          format: ['camelCase', 'UPPER_CASE', 'PascalCase'],
        },
        // 4. Booleans -> PascalCase with verb prefix
        {
          selector: 'variable',
          types: ['boolean'],
          format: ['PascalCase'],
          prefix: ['is', 'should', 'has', 'can', 'did', 'will'],
        },
      ],

      /* --- Bonus: Best Practices --- */
      'no-console': ['warn', { allow: ['warn', 'error', 'info'] }],
    },
  },
];
