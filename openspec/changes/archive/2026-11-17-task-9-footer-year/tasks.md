# Tasks

## 1. Footer date

- [x] 1.1 In `src/App.tsx`, change the footer to render `v<version> (<sha>) · <YYYY-MM-DD>` with the full local date computed from `new Date()` at render time (F1); verify the unchanged `__APP_VERSION__` and `__APP_COMMIT_SHA__` usage and that no styling/className was added.
- [x] 1.2 Run `pnpm build` and verify it succeeds; confirm the date is computed at runtime, not baked in.
- [x] 1.3 Run `pnpm lint` and verify it succeeds.
