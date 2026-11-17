## Context
The footer in `src/App.tsx` renders `v{__APP_VERSION__} ({__APP_COMMIT_SHA__})`, both values injected at build time.

## Goals / Non-Goals
- Goals: append " · <date>" with the full date (`YYYY-MM-DD`) computed in the browser at render.
- Non-Goals: copyright text, company name, styling.

## Decisions
- Compute the date at render time in the component, not via a build-time define, so it reflects the visitor's current date.
- Format as `YYYY-MM-DD` from local date parts (`getFullYear()`, `getMonth() + 1`, `getDate()`, zero-padded). Not `toISOString()`, which uses UTC and can show the wrong local day. Format was unspecified in review feedback F1; ISO-style chosen as unambiguous and locale-independent.
- Render as a single string expression so the footer text is one text node with exactly one " · " separator and no stray whitespace.
- No new dependencies or files.

## Risks / Trade-offs
- Date uses the visitor's local timezone; acceptable for a footer.
