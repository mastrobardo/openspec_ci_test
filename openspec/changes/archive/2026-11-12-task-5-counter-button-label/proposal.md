## Why
The counter button reads "Count is N", which does not say what is counted. Renaming it to "Clicks: N" makes the number easier to read.

## What Changes
- Change the counter button text in `src/App.tsx` from "Count is {count}" to "Clicks: {count}".
- Update the `counter-reset` spec wording that refers to "Count is N" / "Count is 0".
- Update the `main-page-heading` spec wording that names the "Count is" counter button as unchanged text.
- No styling changes; the Reset button is not changed.

## Capabilities

### New Capabilities
None.

### Modified Capabilities
- `counter-reset`: the counter button label is now "Clicks: N" (affects the Reset button placement and post-reset scenarios).
- `main-page-heading`: the "other text unchanged" scenario refers to the counter button by its new label.

## Impact
- `src/App.tsx` (one text node).
- `openspec/specs/counter-reset/spec.md` and `openspec/specs/main-page-heading/spec.md` after archive.
