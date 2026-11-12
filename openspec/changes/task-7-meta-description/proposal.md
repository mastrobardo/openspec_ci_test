## Why

Search results should describe the project. The page currently has no meta description, so search engines pick arbitrary text.

## What Changes

- Add `<meta name="description" content="Proof of concept: OpenSpec changes driven by Claude Code in GitHub Actions." />` to the `<head>` of `index.html`.
- No change to `<title>`, other meta tags, Open Graph tags, or `src/`.

## Capabilities

### New Capabilities
- `page-meta-description`: the page declares a single meta description for search engines.

### Modified Capabilities

None.

## Impact

- `index.html` only (outside `openspec/`).
