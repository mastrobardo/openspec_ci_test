# Proposal

## Why

Users reporting problems cannot tell which app version they run. Showing the version on the main page lets them quote it.

## What Changes

- Add a `<footer>` at the bottom of the main page showing "Version X.Y.Z".
- X.Y.Z is the `version` field of `package.json`, injected at build time (Vite `define` constant), not hard-coded in a component.
- Out of scope: styling beyond readability, git SHA, build date.

## Capabilities

### New Capabilities
- `app-version-footer`: Main page footer displaying the build-time package.json version.

### Modified Capabilities

## Impact

- `vite.config.ts` (define a build-time constant), `src/App.tsx` (footer), a type declaration for the constant under `src/`, minimal CSS in `src/App.css`.
- No new dependencies.
