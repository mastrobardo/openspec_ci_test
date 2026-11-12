# page-meta-description Specification

## Purpose
Gives the page a meta description so search engines can show a summary of the project in results.

## Requirements

### Requirement: Page has a meta description
`index.html` SHALL contain exactly one `<meta name="description">` element in its `<head>` whose content is exactly "Proof of concept: OpenSpec changes driven by Claude Code in GitHub Actions."

#### Scenario: Description present in source
- **WHEN** `index.html` is inspected
- **THEN** it contains exactly one `<meta name="description" content="Proof of concept: OpenSpec changes driven by Claude Code in GitHub Actions." />`

#### Scenario: Description present in build output
- **WHEN** `pnpm build` completes
- **THEN** `dist/index.html` contains the same meta description once

### Requirement: Other head tags unchanged
The `<title>` and all other existing `<meta>` and `<link>` tags in `index.html` MUST remain unchanged, and no Open Graph or social meta tags SHALL be added.

#### Scenario: Existing tags preserved
- **WHEN** `index.html` is inspected after the change
- **THEN** `<title>OpenSpec CI POC</title>`, the charset meta, the viewport meta and the icon link are identical to before, and no `og:` meta tag exists

### Requirement: Description change is isolated
The change MUST NOT modify any file other than `index.html` outside `openspec/`, in particular nothing under `src/`.

#### Scenario: Only index.html modified
- **WHEN** the change is applied
- **THEN** `git diff --name-only` outside `openspec/` lists only `index.html`

### Requirement: Build and lint succeed
The project MUST build with `pnpm build` and pass `pnpm lint` after the change.

#### Scenario: Quality gates pass
- **WHEN** `pnpm build` and `pnpm lint` are run
- **THEN** both complete successfully
