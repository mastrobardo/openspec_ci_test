## Why
The number on the counter button should stand out so users can read it at a glance.

## What Changes
- In `src/App.tsx`, wrap only the `{count}` number of the counter button in a `<strong>` element, giving "Clicks: <strong>3</strong>".
- The word "Clicks:" stays as plain text; the button's text content is unchanged.
- No new CSS (the browser's default bold is used) and no change to the Reset button.

## Capabilities

### New Capabilities
- `counter-display`: how the number on the main page counter button is presented.

### Modified Capabilities
(none)

## Impact
- `src/App.tsx` only. Text content of the button is identical, so `counter-reset` and `main-page-heading` requirements still hold.
