## Why

The footer reads "v0.0.0 (abc1234)". Users filing bug reports do not know what to copy. Labelling it "Version 0.0.0 · abc1234" makes the version and commit SHA clear.

## What Changes

- Footer text changes from `v<version> (<sha>)` to `Version <version> · <sha>` (middle dot U+00B7, single spaces around it).
- Version and SHA still come from the build (`package.json`, git) via the existing `__APP_VERSION__` and `__APP_COMMIT_SHA__` defines.
- No other page text changes. No styling changes, no build date.

## Capabilities

### New Capabilities
None.

### Modified Capabilities
- `app-version-footer`: the footer format requirements (version, SHA, build-time resolution) change to the new text.

## Impact

- `src/App.tsx` (footer JSX only).
- `openspec/specs/app-version-footer/spec.md` updated on archive.
