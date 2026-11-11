# Proposal

## Why

Users reporting problems cannot tell which app version they run. Showing the version on the main page lets them quote it.

## What Changes

- Add a `<footer>` at the bottom of the main page showing "vX.Y.Z".
- X.Y.Z is the `version` field of `package.json`, injected at build time (Vite `define` constant), not hard-coded in a component.
- The footer also shows the git commit SHA of the build (short form), injected at build time. Falls back to "unknown" when git info is unavailable.
- Out of scope: styling beyond readability, build date.

## Capabilities

### New Capabilities
- `app-version-footer`: Main page footer displaying the build-time package.json version.

### Modified Capabilities

## Impact

- `vite.config.ts` (define build-time constants for version and commit SHA), `src/App.tsx` (footer), a type declaration for the constant under `src/`, minimal CSS in `src/App.css`.
- No new dependencies.

## Scope changes from review

- F1 (@mastrobardo, https://github.com/mastrobardo/openspec_ci_test/pull/1#pullrequestreview-5865908905): the git SHA scope note now lives in this section: the footer also shows the short git commit SHA of the build, so the SHA is in scope (build date stays out of scope); `tasks/task-1.txt` is not edited. Overrides original task: yes: "Showing a git SHA or build date." (Out of scope).
- F1 (@mastrobardo, https://github.com/mastrobardo/openspec_ci_test/pull/1#issuecomment-6808838484): the version text is "v0.0.0" (i.e. "v" + package.json version) instead of "Version 0.0.0". Overrides original task: yes: the description and acceptance criteria said the footer shows "Version X.Y.Z" / "Version " followed by the version. (Numbering is from the latest review round; it differs from the earlier F1 above.)
- F2 (@mastrobardo, https://github.com/mastrobardo/openspec_ci_test/pull/1#issuecomment-6808889783): duplicate of the F1 above from the latest round; same requirement, the version text is "v0.0.0". Overrides original task: yes (same override as above).
