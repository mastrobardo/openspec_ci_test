## Context
`src/App.tsx` renders the counter button with the text `Count is {count}`.

## Decision
Change it to `Count is <strong>{count}</strong>`. Keep a single space between "Count is" and the `<strong>` so the text content stays "Count is N". Use the native `<strong>` default styling; add no CSS. Leave the Reset button untouched.

## Risks
Whitespace: JSX must keep the space before `<strong>` on the same line (or use `{' '}`), otherwise the text would read "Count is3".
