# Design

## Context

Vite 8 + React 19 + TypeScript app. `src/App.tsx` renders a fragment of sections; `tsconfig.app.json` includes only `src` and uses `types: ["vite/client"]`. `vite.config.ts` has no config beyond the React plugin. See proposal.md for motivation.

## Goals / Non-Goals

**Goals:**
- Version text derived from `package.json` at build time.

**Non-Goals:**
- Build date, styling beyond readability.

## Decisions

- **Vite `define` constant `__APP_VERSION__`** set in `vite.config.ts` from `package.json`'s `version`. Alternative: `import pkg from '../package.json'` in a component — rejected because it bundles the whole package.json and needs `resolveJsonModule`/tsconfig `include` changes. Alternative: `import.meta.env.VITE_*` — rejected because it needs an env var set outside the code.
- **Read package.json in the config** with `node:fs` `readFileSync` + `JSON.parse` (relative to the config file via `import.meta.url`), avoiding JSON import-attribute and tsconfig.node concerns. `@types/node` is already a dev dependency.
- **Commit SHA via `define` constant `__APP_COMMIT_SHA__`**: resolved in `vite.config.ts` with `git rev-parse --short HEAD` (`node:child_process` `execSync`, stdio piped), falling back to the `GITHUB_SHA` env var (first 7 chars) and then to `"unknown"` so builds never fail without git.
- **Type declaration** `declare const __APP_VERSION__: string` and `declare const __APP_COMMIT_SHA__: string` in `src/vite-env.d.ts` (or a new `src/app-version.d.ts`) so `tsc -b` passes.
- **Footer** is a `<footer>` appended as the last child of the `App` fragment, with a small rule in `App.css` for readable text.

## Risks / Trade-offs

- [ESLint `no-undef` on the global] → typescript-eslint config normally disables `no-undef` for TS files; verify with `pnpm lint`, add a `globals` entry if needed.
- [Dev server doesn't pick up a version change until restart] → Acceptable; the requirement is "rebuild".
