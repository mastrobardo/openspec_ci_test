## Why
The footer shows only version and commit SHA, so the page can look abandoned. Showing the current date signals that the page is alive.

## What Changes
- Append " · <current date>" (full date, `YYYY-MM-DD`, visitor's local timezone) to the footer text in `src/App.tsx`, after the existing version and SHA text.
- The date is computed in the browser at render time (not at build time).
- The rest of the footer text and all styling stay unchanged.

## Capabilities

### New Capabilities
None.

### Modified Capabilities
- `app-version-footer`: adds a requirement that the footer ends with " · " and the current full date.

## Impact
- `src/App.tsx` (footer element) only.
- Out of scope: copyright notice, company name, styling changes.

## Scope changes from review

- F1 (@mastrobardo, https://github.com/mastrobardo/openspec_ci_test/pull/9#pullrequestreview-5937184707): footer shows the full date instead of only the year. Overrides original task: yes (task said "append the current year", e.g. " · 2026"). Format was not specified; assumed `YYYY-MM-DD` in local time as the most conservative, unambiguous choice.
