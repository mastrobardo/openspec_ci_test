## Context
The footer in `src/App.tsx` renders `v{__APP_VERSION__} ({__APP_COMMIT_SHA__})`, both values injected at build time.

## Goals / Non-Goals
- Goals: append " · <year>" with the year computed in the browser at render.
- Non-Goals: copyright text, company name, styling.

## Decisions
- Compute the year with `new Date().getFullYear()` inside the component render, not via a build-time define, so it reflects the visitor's current year.
- Render as a single string expression, e.g. `` {`v${__APP_VERSION__} (${__APP_COMMIT_SHA__}) · ${new Date().getFullYear()}`} ``, so the footer text is one text node with exactly one " · " separator and no stray whitespace.
- No new dependencies or files.

## Risks / Trade-offs
- Year uses the visitor's local timezone; acceptable for a footer.
