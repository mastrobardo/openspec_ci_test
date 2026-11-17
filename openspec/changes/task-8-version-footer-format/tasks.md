## 1. Footer format

- [x] 1.1 In `src/App.tsx`, change the footer content from `v{__APP_VERSION__} ({__APP_COMMIT_SHA__})` to `Version {__APP_VERSION__} · {__APP_COMMIT_SHA__}`, keeping `__APP_VERSION__` and `__APP_COMMIT_SHA__` as the sources (no change to `vite.config.ts`).
- [x] 1.2 Search `src/` to confirm no other text was altered and no hardcoded version or SHA was introduced (e.g. grep `__APP_VERSION__` and `__APP_COMMIT_SHA__` are still the only sources).

## 2. Verification

- [x] 2.1 Run `pnpm build` and confirm it succeeds.
- [x] 2.2 Search the built `dist/` JS for `Version ` and `·` near the footer code, and confirm `"v"` + version / `(` SHA `)` form is gone.
- [x] 2.3 Run `pnpm lint` and confirm it succeeds.
