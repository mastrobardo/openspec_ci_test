## Why

Users can only increment the counter on the main page. To start counting again they must reload the page. A "Reset" button lets them return the count to 0 in place.

## What Changes

- Add a button labelled "Reset" next to the existing "Count is N" button in `src/App.tsx`.
- Clicking "Reset" sets the count to 0. If the count is already 0 it stays 0.
- The Reset button reuses the existing `counter` CSS class. No new styling.

Out of scope: persisting the count, new styling.

## Capabilities

### New Capabilities
- `counter-reset`: a Reset button on the main page that sets the counter back to 0.

### Modified Capabilities
None. The existing `main-page-heading` requirement that other visible text is unchanged applies to the heading change only.

## Impact

- Code: `src/App.tsx` only.
- No dependency, config or stylesheet changes.
