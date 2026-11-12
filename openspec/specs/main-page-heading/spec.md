# main-page-heading Specification

## Purpose
Tells visitors which project they are looking at by giving the main page a primary heading that names the project.

## Requirements

### Requirement: Main page heading names the project
The main page SHALL render exactly one `<h1>` element whose text content is exactly "OpenSpec CI POC", with no leading or trailing text.

#### Scenario: Heading text shown
- **WHEN** the main page is rendered
- **THEN** its `<h1>` element's text content equals "OpenSpec CI POC"

#### Scenario: Placeholder heading removed
- **WHEN** the main page is rendered
- **THEN** the text "Get started" does not appear in any `<h1>` element

### Requirement: Other page text is unchanged
Changing the heading MUST NOT change any other visible text on the main page or the page's styling. The page `<title>` is governed by the `browser-tab-title` capability.

#### Scenario: Surrounding text preserved
- **WHEN** the main page is rendered after the heading change
- **THEN** all visible text other than the `<h1>` matches the text shown before the change, including the "Edit src/App.tsx and save to test HMR" paragraph, the "Clicks:" counter button, the "Documentation" and "Connect with us" sections with their links, and the version footer

#### Scenario: Page title and styling untouched
- **WHEN** the heading change is applied
- **THEN** no stylesheet is modified and the heading change itself does not alter the `<title>` in `index.html`

### Requirement: Build and lint succeed
The project MUST still build with `pnpm build` and pass `pnpm lint` after the heading change.

#### Scenario: Quality gates pass
- **WHEN** `pnpm build` and `pnpm lint` are run
- **THEN** both complete successfully
