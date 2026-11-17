## Why
The footer shows only version and commit SHA, so the page can look abandoned. Showing the current year signals that the page is alive.

## What Changes
- Append " · <current year>" to the footer text in `src/App.tsx`, after the existing version and SHA text.
- The year is computed in the browser at render time (not at build time).
- The rest of the footer text and all styling stay unchanged.

## Capabilities

### New Capabilities
None.

### Modified Capabilities
- `app-version-footer`: adds a requirement that the footer ends with " · " and the current year.

## Impact
- `src/App.tsx` (footer element) only.
- Out of scope: copyright notice, company name, styling changes.
