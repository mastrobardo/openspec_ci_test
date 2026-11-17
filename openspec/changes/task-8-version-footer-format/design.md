## Context

`src/App.tsx` renders `v{__APP_VERSION__} ({__APP_COMMIT_SHA__})` in `<footer>`. The values are injected by `vite.config.ts` defines, which already handle the "unknown" SHA fallback.

## Goals / Non-Goals

**Goals:** change only the footer text format.
**Non-Goals:** styling, build date, changes to `vite.config.ts` or the defines.

## Decisions

- Edit only the footer JSX to `Version {__APP_VERSION__} · {__APP_COMMIT_SHA__}`. In JSX, text and expressions on one line keep single spaces, so the output is "Version 0.0.0 · abc1234". Use the literal `·` character (or `&middot;`).
- Leave the "unknown" SHA fallback: footer reads "Version 0.0.0 · unknown".
- Existing requirements are replaced via MODIFIED deltas, because their text mentions the old format.

## Risks / Trade-offs

- Other specs (`main-page-heading`) mention the version footer only generically; they stay valid.
