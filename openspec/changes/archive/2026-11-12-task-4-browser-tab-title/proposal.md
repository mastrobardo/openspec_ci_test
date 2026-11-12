## Why

Users with many tabs open cannot find the app quickly because the tab shows the generic `openspec-ci-poc` slug. The tab should show the project name "OpenSpec CI POC", matching the main page heading.

## What Changes

- Change the `<title>` in `index.html` from `openspec-ci-poc` to `OpenSpec CI POC`.
- Update the existing `main-page-heading` requirement that pins the title to `openspec-ci-poc`, since it would now contradict the new behavior.
- No other files change. Favicon and dynamic (React-set) titles are out of scope.

## Capabilities

### New Capabilities
- `browser-tab-title`: the static page `<title>` in `index.html` names the project.

### Modified Capabilities
- `main-page-heading`: the "Other page text is unchanged" requirement no longer asserts the old title value.

## Impact

- `index.html` (one line).
- `openspec/specs/main-page-heading/spec.md` is updated at archive time via the delta.
