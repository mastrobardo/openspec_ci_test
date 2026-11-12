## Context
`src/App.tsx` renders the counter button with the text `Clicks: {count}` (the label set by the archived change `task-5-counter-button-label`).

## Decision
Change it to `Clicks: <strong>{count}</strong>`. Keep a single space between "Clicks:" and the `<strong>` so the text content stays "Clicks: N". Use the native `<strong>` default styling; add no CSS. Leave the Reset button untouched.

## Risks
Whitespace: JSX must keep the space before `<strong>` on the same line (or use `{' '}`), otherwise the text would read "Clicks:3".
