## ADDED Requirements

### Requirement: Footer shows the current date
The footer SHALL end with " · " followed by the current full date formatted `YYYY-MM-DD` in the visitor's local timezone, computed in the browser when the page renders. The rest of the footer text (version and commit SHA) MUST remain unchanged.

#### Scenario: Date appended
- **WHEN** the main page is rendered on 2026-11-17 with version `0.0.0` and SHA `abc1234`
- **THEN** the footer text is "v0.0.0 (abc1234) · 2026-11-17"

#### Scenario: Date computed at render time
- **WHEN** the source of the footer is inspected
- **THEN** the date comes from a runtime call such as `new Date()` and not from a build-time constant

#### Scenario: Existing footer text unchanged
- **WHEN** the main page is rendered
- **THEN** the footer text before the final " · <date>" is exactly "v<version> (<sha>)" as before

#### Scenario: Quality gates pass
- **WHEN** `pnpm build` and `pnpm lint` are run after the change
- **THEN** both complete successfully
