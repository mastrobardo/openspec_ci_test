# Proposal

## Why

The main page's `<h1>` still reads "Get started", the Vite template's placeholder. Visitors can't tell from it what the project is. The heading should name the project instead.

## What Changes

- Change the text of the main page's `<h1>` from "Get started" to exactly "OpenSpec CI POC".
- Leave all other text on the page as it is, including the paragraph under the heading, the counter button, the "Documentation" and "Connect with us" sections, and the version footer.
- Out of scope: styling changes, and the page `<title>` in `index.html` (`openspec-ci-poc`). Task 4 covers the title separately.

## Capabilities

### New Capabilities
- `main-page-heading`: the main page's primary heading (`<h1>`) and the text it shows to visitors.

### Modified Capabilities
<!-- None. `app-version-footer` is unaffected; its requirements stay as they are. -->

## Impact

- Code: one string literal in `src/App.tsx` (line 19, `<h1>Get started</h1>`).
- No changes to styling (`src/App.css`, `src/index.css`), `index.html`, dependencies, or build config.
- Quality gates: `pnpm build` and `pnpm lint` must still pass.
