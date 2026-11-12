## MODIFIED Requirements

### Requirement: Other page text is unchanged
Changing the heading MUST NOT change any other visible text on the main page or the page's styling. The page `<title>` is governed by the `browser-tab-title` capability.

#### Scenario: Surrounding text preserved
- **WHEN** the main page is rendered after the heading change
- **THEN** all visible text other than the `<h1>` matches the text shown before the change, including the "Edit src/App.tsx and save to test HMR" paragraph, the "Clicks:" counter button, the "Documentation" and "Connect with us" sections with their links, and the version footer

#### Scenario: Page title and styling untouched
- **WHEN** the heading change is applied
- **THEN** no stylesheet is modified and the heading change itself does not alter the `<title>` in `index.html`
