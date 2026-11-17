# Tasks

## 1. Footer year

- [ ] 1.1 In `src/App.tsx`, change the footer to render `v<version> (<sha>) · <year>` with the year from `new Date().getFullYear()` at render time; verify by searching `src/App.tsx` for `getFullYear` and for the unchanged `__APP_VERSION__` and `__APP_COMMIT_SHA__` usage, and that no styling/className was added.
- [ ] 1.2 Run `pnpm build` and verify it succeeds; search `dist/` JS for `getFullYear` to confirm the year is computed at runtime, not baked in.
- [ ] 1.3 Run `pnpm lint` and verify it succeeds.
