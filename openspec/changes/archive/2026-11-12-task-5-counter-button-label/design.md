## Context
The counter button in `src/App.tsx` renders `Count is {count}`. The text is a single JSX text node.

## Goals / Non-Goals
- Goals: render `Clicks: {count}`; keep Reset behaviour; keep build and lint green.
- Non-goals: styling, Reset button changes, any other text.

## Decisions
- Edit only the JSX text node, keeping the `{count}` expression so the label is "Clicks: 0" on load and after Reset.
- Use a MODIFIED delta for the affected requirements (full requirement text restated) rather than adding new capabilities.
