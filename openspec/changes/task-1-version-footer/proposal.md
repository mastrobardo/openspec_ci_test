# Proposal

## Why

Users reporting problems cannot tell which app version they run. Showing the version on the main page lets them quote it.

## What Changes

- Add a `<footer>` at the bottom of the main page showing "Version X.Y.Z".
- X.Y.Z is the `version` field of `package.json`, injected at build time (Vite `define` constant), not hard-coded in a component.
- The footer also shows the git commit SHA of the build (short form), injected at build time. Falls back to "unknown" when git info is unavailable.
- **Scope change (reviewer feedback, review round 2 F1):** `tasks/task-1.txt` originally listed "Showing a git SHA or build date" as out of scope. The reviewer asked for the SHA to be recorded as a scope change, so the git SHA is now in scope; the original task text is not edited.
- Out of scope: styling beyond readability, build date.

## Capabilities

### New Capabilities
- `app-version-footer`: Main page footer displaying the build-time package.json version.

### Modified Capabilities

## Impact

- `vite.config.ts` (define build-time constants for version and commit SHA), `src/App.tsx` (footer), a type declaration for the constant under `src/`, minimal CSS in `src/App.css`.
- No new dependencies.
